Feature: Batch action update

  Background:
    Given A new admin user with username "admin1"
     And "2" destinations

  @javascript
  Scenario: Update boolean field
    When I signed in as admin user with username "admin1"
    And I open the "destinations" page
    And I click checkbox to select all records
    And I click the batch actions button and choose change_attributes
    And I update attribute "enabled" with value "false"
    Then The destinations attribute "enabled" should be updated to "[false, false]"

  @javascript
  Scenario: Update number field
    When I signed in as admin user with username "admin1"
    And I open the "destinations" page
    And I click checkbox to select all records
    And I click the batch actions button and choose change_attributes
    And I update attribute "initial_rate" with value "3.0"
    Then The destinations attribute "initial_rate" should be updated to "[3.0, 3.0]"

  @javascript
  Scenario: Try update with invalid value
    When I signed in as admin user with username "admin1"
    And I open the "destinations" page
    And I click checkbox to select all records
    And I click the batch actions button and choose change_attributes
    And I update attribute "connect_fee" with value "test"
    Then The destinations attribute "connect_fee" should not be updated
    And flash error panel should be shown

  @javascript
  Scenario: dropdown_menu_button is not disabled if any record selected
    When I signed in as admin user with username "admin1"
    And I open the "destinations" page
    Then The dropdown_menu_button is disabled
    When I click checkbox to select all records
    Then The dropdown_menu_button is not disabled
