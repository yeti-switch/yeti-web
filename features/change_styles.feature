Feature: Change styles

  @change_color
  @javascript
  Scenario: change_color
    Given a new admin user with username "admin1"
    When I open variables.css.scss file and override variable "$text-color: blue !default;"
    And I signed in as admin user with username "admin1"
    And I open the dashboard page
    Then The page text should be blue

  @change_logo_src
  @javascript
  Scenario: change logo src
    Given A new admin user with username "admin1"
    When I create active_admin yml file and add site title "site_title: 'Yeti Admin'"
    And I add site image src "site_title_image: '/images/logo.png'"
    And Reinitialize ActiveAdmin
    And I signed in as admin user with username "admin1"
    And I open the dashboard page
    Then The title image src should be "/images/logo.png"