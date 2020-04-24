import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class PledgeViewCTAContainerViewModelTests: TestCase {
  let vm: PledgeViewCTAContainerViewModelType = PledgeViewCTAContainerViewModel()
  private let hideApplePayButton = TestObserver<Bool, Never>()
  private let hideContinueButton = TestObserver<Bool, Never>()
  private let hideSubmitButton = TestObserver<Bool, Never>()
  private let notifyDelegateApplePayButtonTapped = TestObserver<Void, Never>()
  private let notifyDelegateOpenHelpType = TestObserver<HelpType, Never>()
  private let notifyDelegateSubmitButtonTapped = TestObserver<Void, Never>()
  private let notifyDelegateToGoToLoginSignup = TestObserver<Void, Never>()
  private let submitButtonIsEnabled = TestObserver<Bool, Never>()
  private let submitButtonTitle = TestObserver<String, Never>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.hideApplePayButton.observe(self.hideApplePayButton.observer)
    self.vm.outputs.hideContinueButton.observe(self.hideContinueButton.observer)
    self.vm.outputs.hideSubmitButton.observe(self.hideSubmitButton.observer)
    self.vm.outputs.notifyDelegateApplePayButtonTapped
      .observe(self.notifyDelegateApplePayButtonTapped.observer)
    self.vm.outputs.notifyDelegateOpenHelpType.observe(self.notifyDelegateOpenHelpType.observer)
    self.vm.outputs.notifyDelegateSubmitButtonTapped.observe(self.notifyDelegateSubmitButtonTapped.observer)
    self.vm.outputs.notifyDelegateToGoToLoginSignup.observe(self.notifyDelegateToGoToLoginSignup.observer)
    self.vm.outputs.submitButtonIsEnabled.observe(self.submitButtonIsEnabled.observer)
    self.vm.outputs.submitButtonTitle.observe(self.submitButtonTitle.observer)
  }

  func testPledgeView_UserLoggedOut() {
    let context = PledgeViewContext.pledge

    let pledgeData = PledgeViewCTAContainerViewData(
      isLoggedIn: false,
      isEnabled: true,
      title: context.submitButtonTitle,
      context: context
    )

    self.vm.inputs.configureWith(value: pledgeData)

    self.hideSubmitButton.assertValues([true])
    self.hideApplePayButton.assertValues([true])
    self.hideContinueButton.assertValues([false])
    self.submitButtonIsEnabled.assertValues([true])
  }

  func testPledgeView_UpdateContext_UserLoggedOut() {
    let context = PledgeViewContext.update

    let pledgeData = PledgeViewCTAContainerViewData(
      isLoggedIn: true,
      isEnabled: true,
      title: context.submitButtonTitle,
      context: context
    )

    self.vm.inputs.configureWith(value: pledgeData)

    self.hideSubmitButton.assertValues([false])
    self.hideApplePayButton.assertValues([true])
    self.hideContinueButton.assertValues([true])
    self.submitButtonIsEnabled.assertValues([true])
    self.submitButtonTitle.assertValues(["Confirm"])
  }

  func testPledgeView_PledgeContext_UserLoggedOut() {
    let context = PledgeViewContext.pledge

    let pledgeData = PledgeViewCTAContainerViewData(
      isLoggedIn: true,
      isEnabled: true,
      title: context.submitButtonTitle,
      context: context
    )

    self.vm.inputs.configureWith(value: pledgeData)

    self.hideSubmitButton.assertValues([false])
    self.hideApplePayButton.assertValues([false])
    self.hideContinueButton.assertValues([true])
    self.submitButtonIsEnabled.assertValues([true])
    self.submitButtonTitle.assertValues(["Pledge"])
  }

  func testContinueButtonTapped() {
    let pledgeData = PledgeViewCTAContainerViewData(
      isLoggedIn: false,
      isEnabled: true,
      title: Strings.Pledge(),
      context: .pledge
    )

    self.vm.inputs.configureWith(value: pledgeData)

    self.notifyDelegateToGoToLoginSignup.assertDidNotEmitValue()

    self.vm.inputs.continueButtonTapped()

    self.notifyDelegateToGoToLoginSignup.assertValueCount(1)
  }

  func testApplePayButtonTapped() {
    self.notifyDelegateApplePayButtonTapped.assertDidNotEmitValue()

    self.vm.inputs.applePayButtonTapped()

    self.notifyDelegateApplePayButtonTapped.assertValueCount(1)
  }

  func testNotifyDelegateOpenHelpType() {
    let baseUrl = AppEnvironment.current.apiService.serverConfig.webBaseUrl
    let allCases = HelpType.allCases.filter { $0 != .contact }

    let allHelpTypeUrls = allCases.map { $0.url(withBaseUrl: baseUrl) }.compact()

    allHelpTypeUrls.forEach { self.vm.inputs.tapped($0) }

    self.notifyDelegateOpenHelpType.assertValues(allCases)
  }

  func testSubmitButtonTapped() {
    self.notifyDelegateSubmitButtonTapped.assertDidNotEmitValue()

    self.vm.inputs.submitButtonTapped()

    self.notifyDelegateSubmitButtonTapped.assertValueCount(1)
  }
}
