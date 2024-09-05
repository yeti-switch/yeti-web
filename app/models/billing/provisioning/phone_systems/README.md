# Billing::Provisioning::PhoneSystems

This module is responsible for provisioning customers and services through the phone.systems platform.
It provides an interface for creating and deleting customers in an external VoIP or telecom system through
REST API interactions. The code follows clean architecture principles, making it easy to extend and maintain.

## Overview

The `Billing::Provisioning::PhoneSystems` namespace handles communication with the external `phone.systems` API.
This includes managing customer data such as creating new customers, deleting customers, and sending necessary service
variables for the telecom center.

The main classes and schemas in this module ensure data validation, API interaction,
and seamless handling of customer records.

## Key Components

- `CustomerService`: Manages operations for creating and deleting customers on phone.systems.
It sends payloads to the API and processes the response.
- `PhoneSystemsApiClient`: Handles HTTP requests to the phone.systems API. It sends POST and DELETE requests for
creating and deleting customers with the appropriate authentication and headers.
- `ServiceTypeSchema` and `ServiceVariablesSchema`: These define validation rules for the service data
(like endpoint, username, password, and customer attributes). These schemas ensure only valid data is sent to the
phone.systems API.
- `ServiceTypeVariablesContract` and `ServiceVariablesContract`: These contracts apply the validation logic from the
schemas, ensuring consistency in data formats and preventing invalid data from being sent to the API.

## ServiceTypeSchema Example

```json
{
  endpoint: 'https://api.sandbox.telecom.center',
  username: 'test',
  password: 'test',
  attributes: {
    name: 'Customer Name',
    language: 'EN',
    capacity_limit: 100,
    "trm_mode": 'operator',
    sip_account_limit: 50
  }
}
```
