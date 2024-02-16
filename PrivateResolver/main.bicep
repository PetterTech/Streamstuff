targetScope = 'resourceGroup'

param location string = 'norwayeast'
param localAdminUsername string = 'pettertech'
@secure()
param localAdminPassword string = 'LongAndStrongP@ssw0rd1234'

module hubvnet './hubvnet.bicep' = {
  name: 'hubvnet'
  params: {
    location: location
  }
}

module spokevnet './spokevnet.bicep' = {
  name: 'spokevnet'
  params: {
    location: location
  }
}

module onpremvnet './onpremvnet.bicep' = {
  name: 'onpremvnet'
  params: {
    location: location
  }
}

module VMs './VMs.bicep' = {
  name: 'VMs'
  params: {
    location: location
    localAdminUsername: localAdminUsername
    localAdminPassword: localAdminPassword
    onpremsubnetID: onpremvnet.outputs.onpremsubnetID
    spokesubnetID: spokevnet.outputs.spokesubnetID
  }
}

module vnetpeering './vnetPeering.bicep' = {
  name: 'vnetpeering'
  params: {
    HubID: hubvnet.outputs.vnetID
    Spoke1ID: spokevnet.outputs.vnetID
    Spoke2ID: onpremvnet.outputs.vnetID
  }
}

module bastion 'bastion.bicep' = {
  name: 'bastion'
  params: {
    HubSubnetID: hubvnet.outputs.bastionSubnetID
    location: location
  }
}

module privateresolver 'privateresolver.bicep' = {
  name: 'privateresolver'
  params: {
    location: location
    hubvnetID: hubvnet.outputs.vnetID
    inboundSubnetID: hubvnet.outputs.inboundSubnetID
    outboundSubnetID: hubvnet.outputs.outboundSubnetID
  }
}

module storage 'storage.bicep' = {
  name: 'storage'
  params: {
    location: location
    hubVnetID: hubvnet.outputs.vnetID
    spokeVnetID: spokevnet.outputs.vnetID
    spokeSubnetID: spokevnet.outputs.spokesubnetID
  }
}
