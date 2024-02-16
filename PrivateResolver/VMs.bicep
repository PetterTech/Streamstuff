param location string
param localAdminUsername string
@secure()
param localAdminPassword string
param onpremsubnetID string
param spokesubnetID string

resource OnPremVMNic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: 'OnPremVMNic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: onpremsubnetID
          }
        }
      }
    ]
  }
}

resource SpokeVMNic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: 'SpokeVMNic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: spokesubnetID
          }
        }
      }
    ]
  }
}

resource OnPremVM 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: 'OnPremVM'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D4s_v5'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'windows-11'
        sku: 'win11-23h2-ent'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    osProfile: {
      computerName: 'OnPremVM'
      adminUsername: localAdminUsername
      adminPassword: localAdminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: OnPremVMNic.id
        }
      ]
    }    
  }
}

resource SpokeVM 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: 'SpokeVM'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D4s_v5'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'windows-11'
        sku: 'win11-23h2-ent'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    osProfile: {
      computerName: 'SpokeVM'
      adminUsername: localAdminUsername
      adminPassword: localAdminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: SpokeVMNic.id
        }
      ]
    }    
  }
}

resource autoShutdownOnPrem 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: 'shutdown-computevm-OnPremVM'
  location: location
  properties: {
    status: 'Enabled'
    dailyRecurrence: {
      time: '17:00'
    }
    timeZoneId: 'UTC'
    targetResourceId: OnPremVM.id
    taskType: 'ComputeVmShutdownTask'
  }
}

resource autoShutdownSpoke 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: 'shutdown-computevm-SpokeVM'
  location: location
  properties: {
    status: 'Enabled'
    dailyRecurrence: {
      time: '17:00'
    }
    timeZoneId: 'UTC'
    targetResourceId: SpokeVM.id
    taskType: 'ComputeVmShutdownTask'
  }
}
