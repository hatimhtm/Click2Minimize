import Foundation
import ServiceManagement

protocol AppServiceProtocol {
    var status: SMAppService.Status { get }
    func register() throws
    func unregister() throws
}

extension SMAppService: AppServiceProtocol {}
