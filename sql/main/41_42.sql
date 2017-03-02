begin;
insert into sys.version(number,comment) values(42,'Notifications');

CREATE TABLE notifications.alerts(
  id serial primary key,
  event varchar not null unique,
  send_to integer[]
);

INSERT INTO notifications.alerts (event) VALUES ('DialpeerLocked');
INSERT INTO notifications.alerts (event) VALUES ('GatewayLocked');

commit;