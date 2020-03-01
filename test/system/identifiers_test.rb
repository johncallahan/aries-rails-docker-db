require "application_system_test_case"

class IdentifiersTest < ApplicationSystemTestCase
  setup do
    @identifier = identifiers(:one)
  end

  test "visiting the index" do
    visit identifiers_url
    assert_selector "h1", text: "Identifiers"
  end

  test "creating a Identifier" do
    visit identifiers_url
    click_on "New Identifier"

    fill_in "Did", with: @identifier.did
    fill_in "Verkey", with: @identifier.verkey
    click_on "Create Identifier"

    assert_text "Identifier was successfully created"
    click_on "Back"
  end

  test "updating a Identifier" do
    visit identifiers_url
    click_on "Edit", match: :first

    fill_in "Did", with: @identifier.did
    fill_in "Verkey", with: @identifier.verkey
    click_on "Update Identifier"

    assert_text "Identifier was successfully updated"
    click_on "Back"
  end

  test "destroying a Identifier" do
    visit identifiers_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Identifier was successfully destroyed"
  end
end
