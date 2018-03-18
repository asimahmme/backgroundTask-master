//
//  Charger_GaugeUITests.swift
//  Charger GaugeUITests
//
//  Created by Asim Ahmed on 3/17/18.
//  Copyright © 2018 AsimAhmed. All rights reserved.
//

import XCTest

class Charger_GaugeUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //this automated test is to show thatthe pickerwheel works and selects a new value succesfully
    func testExample() {
        
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        //Step1: lauch the aap
        let app = XCUIApplication()
        //Step2: get the textfield
        let textField = app.otherElements.containing(.staticText, identifier:"Seconds").children(matching: .textField).element
        textField.tap()
        let textfield = app.textFields.element(boundBy: 0)
        //Step3: Read textfield's value before using the picker wheel to select any value
        XCTAssertTrue(textfield.value as! String  == "Select Interval") // this assertion will return true
      
        //Ste4: Use picker wheel to swipe up and select the last value, 3600 seconds
        app/*@START_MENU_TOKEN@*/.pickerWheels["15.0"]/*[[".pickers.pickerWheels[\"15.0\"]",".pickerWheels[\"15.0\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeUp()
        textField.tap()
        app.toolbars["Toolbar"].buttons["Done"].tap()

    
       let tf = app.textFields.count
        XCTAssertEqual(tf, 1)
        //Step 5: Read the textfield value now, it should be changed to 3600 seconds, showing picker wheel works as expected
        XCTAssertTrue(textfield.value as! String  == "3600.0") // this assertion will also return true

    }
    
}
