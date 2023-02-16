@description('The name of the IoT Hub')
param iotHubName string

@description('The location of the Iot Hub')
param location string

@description('The name of the IotHub SKU')
param skuName string = 'B1'

@description('The capacity of the IotHub SKU')
param capacity int = 1

resource iotHub 'Microsoft.Devices/IotHubs@2022-04-30-preview' = {
  name: iotHubName
  location: location
  sku: {
    name: skuName
    capacity: capacity
  }
}

resource iotHubEventHub 'Microsoft.Devices/IotHubs/eventHubEndpoints/ConsumerGroups@2022-04-30-preview' = {
  name: '${iotHubName}/events/AgoraConsumerGroup'
  properties: {
    name: 'AgoraConsumerGroup'
  }
}

output iotHubHostName string = iotHub.properties.hostName
output iotHubId string = iotHub.id
output iotHubConsumerGroup string = iotHubEventHub.name
output iotHubSharedAccessPolicyName string = iotHub.properties.eventHubEndpoints.events.endpoint
