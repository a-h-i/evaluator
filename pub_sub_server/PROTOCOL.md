


Clients subscribe to and unsubscribe from event targets by emitting subscribe and unsubscribe events.


## Format

### unsubscribe

```
{
  target: <identifier>
}
```

No authentication is required to unsubscribe yourself from any target, has no effect if not subscribed.
No reply is sent by the server


### subscrube

```
{
  target: <identifier>,
  token: <logintoken>,
  target_type: <target_types>
}
```

valid target types : `self`

Server reply
```
{
  status: <boolean>
}
```
true indicates success, false indicates insufficient permissions.