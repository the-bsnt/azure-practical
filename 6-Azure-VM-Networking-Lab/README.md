# Azure VM Networking Lab — VNet, NSG, NIC & VM Provisioning

## Overview

This lab covers building out core Azure networking components from scratch and attaching them to VMs — first via the Portal (GUI), then via Azure CLI — culminating in two RHEL VMs on the same subnet with verified network connectivity between them.

---

## Phase 1 — Core Networking Foundation

**Objective:** Stand up the base network fabric.

- Created a **Virtual Network (VNet)** with address space `192.168.34.0/24`
- Defined **3 subnets** within the VNet (carved out of the /24 range)
- Created a **Public IP address** resource (for later NIC association)
- Created a **Network Security Group (NSG)** and associated it with the subnet

**Resources created:**
| Resource | Type | Notes |
|---|---|---|
| VNet | Virtual Network | `192.168.34.0/24` |
| Subnets (x3) | Subnet | Carved from the VNet range |
| Public IP | Public IP Address | Standard/Basic SKU (as selected) |
| NSG | Network Security Group | Bound to subnet |

---

## Phase 2 — NIC Creation & IP Association

**Objective:** Create a standalone NIC and wire up addressing before VM creation.

- Created a **Network Interface Card**: `tyler-nic-01`
  - Placed inside the VNet + subnet from Phase 1
- **Attached the Public IP** (from Phase 1) to `tyler-nic-01`
- Configured a **static private IP** on the NIC (instead of dynamic/DHCP-assigned)

**Key resource:** `tyler-nic-01` — pre-created NIC with public IP + static private IP, ready to be attached to a VM.

---

## Phase 3 — First VM via Portal (GUI Limitation Discovered)

**Objective:** Create the VM, attach OS disk, and connect it to the network.

- Noted that the **OS disk** is created _during_ VM provisioning (since it requires an OS image) rather than pre-created standalone
- Attempted to attach `tyler-nic-01` (pre-created NIC) to a new VM via the **Azure Portal**
  - **Finding:** The Azure Portal GUI does **not** support attaching a pre-existing/already-created NIC during VM creation — it only allows creating a new NIC inline
- **Workaround used:** Created VM `tyler-redhat-01` and let Azure auto-create a new NIC in the same VNet/subnet
- Defined **NSG inbound rules** for the VM (e.g., SSH access)

**Key resource:** `tyler-redhat-01` — created with an auto-generated NIC (not `tyler-nic-01`), due to Portal limitation.

---

## Phase 4 — Second VM via CLI (Existing NIC Attachment)

**Objective:** Prove that attaching a pre-created NIC to a VM is possible via CLI (bypassing the GUI limitation).

- Created VM `tyler-redhat-02` via **Azure CLI**, explicitly attaching the **pre-existing** `tyler-nic-01`
- Deployment succeeded
- **Connectivity test:** Pinged `tyler-redhat-01` from `tyler-redhat-02` (same subnet) — **reachable, verified**

**Key resource:** `tyler-redhat-02` — attached to `tyler-nic-01` via `az vm create --nics tyler-nic-01`, confirming CLI supports what the Portal GUI does not.

---

## Summary Table

| Phase | Action                                                      | Method | Result                                  |
| ----- | ----------------------------------------------------------- | ------ | --------------------------------------- |
| 1     | VNet + 3 subnets + Public IP + NSG                          | Portal | ✅                                      |
| 2     | NIC (`tyler-nic-01`) + static private IP + public IP attach | Portal | ✅                                      |
| 3     | VM `tyler-redhat-01` + inline NIC + NSG inbound rules       | Portal | ✅ (GUI can't attach pre-made NIC)      |
| 4     | VM `tyler-redhat-02` attached to `tyler-nic-01`             | CLI    | ✅ Ping to `tyler-redhat-01` successful |

---

## Suggested Next Phases

### Phase 5 — Connectivity & Security Hardening

- Test cross-subnet connectivity (move one VM into a different subnet from the 3 created in Phase 1, verify routing/NSG behavior)
- Add **NSG deny rules** and test that unwanted traffic is actually blocked (not just that allowed traffic works)
- Explore **Application Security Groups (ASGs)** for rule management at scale instead of per-IP/per-subnet rules
- Enable **NSG Flow Logs** + **Traffic Analytics** to visualize actual traffic patterns

### Phase 6 — Routing & Segmentation

- Create a **User Defined Route (UDR) / Route Table** and force traffic through a specific path (e.g., simulate a hub-spoke pattern)
- Set up **VNet Peering** to a second VNet and test cross-VNet connectivity
- Explore **Azure Bastion** for secure RDP/SSH without exposing public IPs on VMs directly (removes need for public IP per VM long-term)

### Phase 7 — High Availability & Load Balancing

- Put `tyler-redhat-01` and `tyler-redhat-02` behind an **Azure Load Balancer** (internal or public) and test traffic distribution
- Convert the two VMs into an **Availability Set** or spread across **Availability Zones**
- Test failover behavior (stop one VM, confirm LB routes only to the healthy one)

### Phase 8 — Infrastructure as Code

- Rebuild Phases 1–4 using **Bicep** or **Terraform** instead of manual CLI/Portal steps — good next step given your CLI comfort level already
- Parameterize VNet/subnet/NIC naming so the same template can spin up dev/test/prod

### Phase 9 — DNS & Private Connectivity

- Set up **Azure Private DNS Zone** for internal name resolution between `tyler-redhat-01` and `tyler-redhat-02` instead of relying on IPs
- Explore **Private Endpoints** for PaaS services (e.g., if you later attach a PostgreSQL Flexible Server or Storage Account, connect it privately into this VNet)

### Phase 10 — Monitoring & Governance

- Enable **Azure Monitor / VM Insights** on both VMs
- Set up **Cost alerts / budgets** scoped to this resource group
- Tag resources consistently (`environment`, `owner`, `purpose`) for cleanup and cost tracking later

---

_A natural first pick given your current trajectory: **Phase 6 (VNet Peering + Bastion)** — it directly builds on the NIC/public-IP work you just did and starts moving you toward not needing public IPs on every VM, which ties into the security patterns you've been applying elsewhere (e.g., the clipboard service's OAuth-restricted design)._
