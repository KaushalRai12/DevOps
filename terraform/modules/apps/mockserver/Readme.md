# Mockserver

See https://www.mock-server.com/ for an overview.

## Creating Expectations

Documentation: https://www.mock-server.com/mock_server/creating_expectations.html

## Expectation Lists

You can see the expectations already set up on the server by going to /mockserver/dashboard, but the list below
indicates what calls we're trying to mock:

### Network Topology

- Get node from FSAN - GET /networks/nodes/ZNTS12345
- Get node from ID (Parent) - GET /networks/nodes/1
- Get Network 0 GET /networks/1

### ONT Status

All the below calls are implemented for Cached (GET /networks/nodes/{networkIdentifier}/status?count=1)
Refresh (POST /networks/nodes/{networkIdentifier}/status/refresh)

#### GPON Core

- [x] All Good / (48575443|ZNTS|CXNK)000.{5}
- [x] Inactive / (48575443|ZNTS|CXNK)600.{5}
- [x] Possible Conflict / (48575443|ZNTS|CXNK)700.{5}
- [x] Possible Fibre Fault (48575443|ZNTS|CXNK)100.{5}
- [x] Possible Power Down (48575443|ZNTS|CXNK)200.{5}
- [x] RX Light Levels Abnormal (48575443|ZNTS|CXNK)300.{5}
- [x] TX Light Levels Abnormal (48575443|ZNTS|CXNK)500.{5}
- [x] SFP Light Levels Abnormal (48575443|ZNTS|CXNK)400.{5}
- [x] Start Up Failure / (48575443|ZNTS|CXNK)800.{5}

#### ActiveE

- [x] All Good / VT-MBT-AG-.{4}
- [x] No Active Order / VT-MBT-NO-.{4}
- [x] No Active Service / VT-MBT-NS-.{4}
- [x] No Device Has Been Connected / VT-MBT-ND-.{4}
- [x] Possible Fibre Fault / VT-MBT-LD-.{4}
- [x] Possible Power Down / VT-MBT-PD-.{4}
- [x] RX Light Levels Abnormal / VT-MBT-RA-.{4}
- [x] TX Light Levels Abnormal / VT-MBT-TA-.{4}
- [x] SFP Light Levels Abnormal / VT-MBT-SA-.{4}
- [x] SFP RX Light Levels Abnormal / VT-MBT-SR-.{4}

#### GPON Reach

## Outstanding Expectations

- Any calls needed to do a device check
- Any calls needed to do provisioning
	- Deprovision
	- Provision
	- Assign
