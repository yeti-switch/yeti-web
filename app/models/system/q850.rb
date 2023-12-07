# frozen_string_literal: true

class System::Q850
  CAUSE1 = 1
  CAUSE2 = 2
  CAUSE3 = 3
  CAUSE4 = 4
  CAUSE5 = 5
  CAUSE6 = 6
  CAUSE7 = 7
  CAUSE8 = 8
  CAUSE9 = 9
  CAUSE13 = 13

  CAUSE16 = 16
  CAUSE17 = 17
  CAUSE18 = 18
  CAUSE19 = 19
  CAUSE20 = 20
  CAUSE21 = 21
  CAUSE22 = 22
  CAUSE23 = 23
  CAUSE25 = 25
  CAUSE26 = 26
  CAUSE27 = 27
  CAUSE28 = 28
  CAUSE29 = 29
  CAUSE30 = 30
  CAUSE31 = 31

  CAUSE34_NOCIRCUIT = 34
  CAUSE38 = 38
  CAUSE39 = 39
  CAUSE40 = 40
  CAUSE41 = 41
  CAUSE42 = 42
  CAUSE43 = 43
  CAUSE44 = 44
  CAUSE46 = 46
  CAUSE47 = 47

  CAUSE49 = 49
  CAUSE50 = 50
  CAUSE53 = 53
  CAUSE55 = 55
  CAUSE57 = 57
  CAUSE58 = 58
  CAUSE62 = 62
  CAUSE63 = 63

  CAUSE65 = 65
  CAUSE66 = 66
  CAUSE69 = 69
  CAUSE70 = 70
  CAUSE79 = 79

  CAUSE81 = 81
  CAUSE82 = 82
  CAUSE83 = 83
  CAUSE84 = 84
  CAUSE85 = 85
  CAUSE86 = 86
  CAUSE87 = 87
  CAUSE88 = 88
  CAUSE90 = 90
  CAUSE91 = 91
  CAUSE95 = 95

  CAUSE96 = 96
  CAUSE97 = 97
  CAUSE98 = 98
  CAUSE99 = 99
  CAUSE100 = 100
  CAUSE101 = 101
  CAUSE102 = 102
  CAUSE103 = 103

  CAUSE110 = 110
  CAUSE111 = 111

  CAUSE127 = 127

  CAUSES = {
    CAUSE1 => '1 Unallocated (unassigned) number',
    CAUSE2 => '2 No route to specified transit network (national use)',
    CAUSE3 => '3 No route to destination',
    CAUSE4 => '4 Send special information tone',
    CAUSE5 => '5 Misdialled trunk prefix (national use)',
    CAUSE6 => '6 Channel unacceptable',
    CAUSE7 => '7 Call awarded and being delivered in an established channel',
    CAUSE8 => '8 Pre-emption',
    CAUSE9 => '9 Pre-emption – circuit reserved for reuse',
    CAUSE13 => '13 Call completed elsewhere',

    CAUSE16 => '16 Normal call clearing',
    CAUSE17 => '17 User busy',
    CAUSE18 => '18 No user responding',
    CAUSE19 => '19 No answer from user (user alerted)',
    CAUSE20 => '20 Subscriber absent',
    CAUSE21 => '21 Call rejected ',
    CAUSE22 => '22 Number changed',
    CAUSE23 => '23 Redirection to new destination',
    CAUSE25 => '25 Exchange – routing error',
    CAUSE26 => '26 Non-selected user clearing',
    CAUSE27 => '27 Destination out of order',
    CAUSE28 => '28 Invalid number format (address incomplete)',
    CAUSE29 => '29 Facility rejected',
    CAUSE30 => '30 Response to STATUS ENQUIRY',
    CAUSE31 => '31 Normal, unspecified',

    # 6.2.7.2 Resource unavailable class
    CAUSE34_NOCIRCUIT => '34 No circuit/channel available',
    CAUSE38 => '38 Network out of order',
    CAUSE39 => '39 Permanent frame mode connection out of service',
    CAUSE40 => '40 Permanent frame mode connection operational',
    CAUSE41 => '41 Temporary failure',
    CAUSE42 => '42 Switching equipment congestion',
    CAUSE43 => '43 Access information discarded',
    CAUSE44 => '44 Requested circuit/channel not available',
    CAUSE46 => '46 Precedence call blocked',
    CAUSE47 => '47 Resource unavailable, unspecified',

    # 6.2.7.3 Service or option unavailable class
    CAUSE49 => '49 Quality of service not available',
    CAUSE50 => '50 Requested facility not subscribed',
    CAUSE53 => '53 Outgoing calls barred within CUG',
    CAUSE55 => '55 Incoming calls barred within CUG',
    CAUSE57 => '57 Bearer capability not authorized',
    CAUSE58 => '58 Bearer capability not presently available',
    CAUSE62 => '62 Inconsistency in designated outgoing access information and subscriber class',
    CAUSE63 => '63 Service or option not available, unspecified',

    # Service or option not implemented class
    CAUSE65 => '65 Bearer capability not implemented',
    CAUSE66 => '66 Channel type not implemented',
    CAUSE69 => '69 Requested facility not implemented',
    CAUSE70 => '70 Only restricted digital information bearer capability is available',
    CAUSE79 => '79 Service or option not implemented, unspecified',

    # Invalid message (e.g., parameter out of range) class
    CAUSE81 => '81 Invalid call reference value',
    CAUSE82 => '82 Identified channel does not exist',
    CAUSE83 => '83 A suspended call exists, but this call identity does not',
    CAUSE84 => '84 Call identity in use',
    CAUSE85 => '85 No call suspended',
    CAUSE86 => '86 Call with the requested call identity has been cleared',
    CAUSE87 => '87 User not member of CUG',
    CAUSE88 => '88 Incompatible destination',
    CAUSE90 => '90 Non-existent CUG',
    CAUSE91 => '91 Invalid transit network selection (national use)',
    CAUSE95 => '95 Invalid message, unspecified',

    # Protocol error (e.g., unknown message) class
    CAUSE96 => '96 Mandatory information element is missing',
    CAUSE97 => '97 Message type non-existent or not implemented',
    CAUSE98 => '98 Message not compatible with call state or message type non-existent or not implemented',
    CAUSE99 => '99 Information element/parameter non-existent or not implemented',
    CAUSE100 => '100 Invalid information element contents',
    CAUSE101 => '101 Message not compatible with call state',
    CAUSE102 => '102 Recovery on timer expiry',
    CAUSE103 => '103 Parameter non-existent or not implemented – passed on (national use)',

    CAUSE110 => '110 Message with unrecognized parameter discarded',
    CAUSE111 => '111 Protocol error, unspecified',
    # Interworking class
    CAUSE127 => '127 Interworking, unspecified'

  }.freeze
end
