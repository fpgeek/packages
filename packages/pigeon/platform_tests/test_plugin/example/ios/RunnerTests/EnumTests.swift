// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
@testable import test_plugin

class MockEnumApi2Host: EnumApi2Host {
  func echo(data: DataWithEnum) -> DataWithEnum {
    return data
  }
}

extension DataWithEnum: Equatable {
  public static func == (lhs: DataWithEnum, rhs: DataWithEnum) -> Bool {
    lhs.state == rhs.state
  }
}

class EnumTests: XCTestCase {

  func testEchoHost() throws {
    let binaryMessenger = MockBinaryMessenger<DataWithEnum>(codec: EnumApi2HostCodec.shared)
    EnumApi2HostSetup.setUp(binaryMessenger: binaryMessenger, api: MockEnumApi2Host())
    let channelName = "dev.flutter.pigeon.EnumApi2Host.echo"
    XCTAssertNotNil(binaryMessenger.handlers[channelName])

    let input = DataWithEnum(state: .success)
    let inputEncoded = binaryMessenger.codec.encode([input])

    let expectation = XCTestExpectation(description: "echo")
    binaryMessenger.handlers[channelName]?(inputEncoded) { data in
      let outputMap = binaryMessenger.codec.decode(data) as? [String: Any]
      XCTAssertNotNil(outputMap)

      let output = outputMap?["result"] as? DataWithEnum
      XCTAssertEqual(output, input)
      XCTAssertNil(outputMap?["error"])
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1.0)
  }

  func testEchoFlutter() throws {
    let data = DataWithEnum(state: .error)
    let binaryMessenger = EchoBinaryMessenger(codec: EnumApi2HostCodec.shared)
    let api = EnumApi2Flutter(binaryMessenger: binaryMessenger)

    let expectation = XCTestExpectation(description: "callback")
    api.echo(data: data) { result in
      XCTAssertEqual(data.state, result.state)
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1.0)
  }

}
