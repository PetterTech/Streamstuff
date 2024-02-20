param location string
param hubvnetID string
param inboundSubnetID string
param outboundSubnetID string

resource privateResolver 'Microsoft.Network/dnsResolvers@2022-07-01' = {
  name: 'privateResolver'
  location: location
  properties: {
    virtualNetwork: {
      id: hubvnetID
    }
  }
}

resource inboundEndpoint 'Microsoft.Network/dnsResolvers/inboundEndpoints@2022-07-01' = {
  name: 'inboundEndpoint'
  location: location
  parent: privateResolver
  properties: {
    ipConfigurations: [
      {
        privateIpAddress: '10.200.0.70'
        privateIpAllocationMethod: 'Static'
        subnet: {
          id: inboundSubnetID
        }
      }
    ]
  }
}

resource outboundEndpoint 'Microsoft.Network/dnsResolvers/outboundEndpoints@2022-07-01' = {
  name: 'outboundEndpoint'
  location: location
  parent: privateResolver
  properties: {
    subnet: {
      id: outboundSubnetID
    }
  }
}

resource LabzoneRuleset 'Microsoft.Network/dnsForwardingRulesets@2022-07-01' = {
  name: 'LabzoneRuleset'
  location: location
  properties: {
    dnsResolverOutboundEndpoints: [
      {
        id: outboundEndpoint.id
      }
    ]
  }
}

resource LabzoneForwarding 'Microsoft.Network/dnsForwardingRulesets/forwardingRules@2022-07-01' = {
  name: 'LabzoneForwarding'
  parent: LabzoneRuleset
  properties: {
    domainName: 'labzone.local.'
    targetDnsServers: [
       {
        ipAddress: '10.100.0.5'
        port: 53
       }
    ]
  }
}
