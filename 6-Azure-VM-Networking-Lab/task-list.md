# Azure VM Deployment – Implementation Phases

## Phase 1 – Network Infrastructure

- Created an **Azure Virtual Network (VNet)**.
- Defined the VNet address space as `192.168.34.0/24`.
- Created **3 subnets** within the VNet.
- Created a **Public IP Address** resource.
- Created a **Network Security Group (NSG)**.
- Associated the NSG with the required subnet.

## Phase 2 – Network Interface Card (NIC)

- Created a NIC within the previously created:
  - Virtual Network
  - Subnet

- Created the NIC named **`tyler-nic-01`**.
- Associated the **Public IP Address** with the NIC.
- Configured a **static private IP address** for the NIC.

## Phase 3 – VM Creation via Azure Portal

- Created a Virtual Machine and its **OS disk**.
- The OS disk was created during VM provisioning because it needs to be based on an OS image.
- Configured the VM to use the existing VNet and subnet.
- The Azure Portal did not provide an option to attach the already-created NIC `tyler-nic-01` during this VM creation workflow.
- As an alternative, created the VM with a new NIC:
  - VM: **`tyler-redhat-01`**
  - NIC: Automatically created during VM provisioning

- Configured **NSG inbound rules** for the VM.
- Configured the operating system and verified that the VM could communicate with the internet through its public IP.

## Phase 4 – VM Creation via Azure CLI

- Created another VM using the **Azure CLI**.
- Attached the previously created NIC **`tyler-nic-01`** to the VM during provisioning.
- Created the VM:
  - VM: **`tyler-redhat-02`**
  - Existing NIC: **`tyler-nic-01`**

- The VM was successfully created with the existing NIC.
- Verified network connectivity between the two VMs by pinging one VM from the other.
- Confirmed that the VMs were reachable over the private network.



NOTE :::: A NIC can be attached to only one subnet, and that subnet belongs to one VNet.
