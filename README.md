<p align="center">
    <img src="eoskit-icon.svg" width="256" align="middle" alt=“EosKit”/>
</p>

# EosKit
Communicate with an [Eos](https://www.etcconnect.com/Products/Consoles/Eos-Family/) console.

## Overview
The EosKit package provides the classes needed for your apps to communicate with an Eos console.

## Installation

#### Xcode 11+
[Add the package dependency](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) to your Xcode project using the following repository URL: 
``` 
https://github.com/SammySmallman/EosKit
```
#### Swift Package Manager

Add the package dependency to your Package.swift and depend on "EosKit" in the necessary targets:

```  swift
dependencies: [
    .package(url: "https://github.com/SammySmallman/EosKit", .branch("master"))
]
```

## Usage

Import into your project files using Swift:

``` swift
import EosKit
```

### First Steps

Obtain an `EosConsole` to use in your app.

#### Automatic

Using `EosBrowser` and providing it a delegate that implements the `EosConsoleDiscovererDelegate` protocol, instances of Eos consoles can be automatically discovered one or more IP networks.

Create the `EosBrowser`:

``` swift
let browser = EosBrowser()
browser.delegate = self
browser.start()
```

Conform to the `EosConsoleDiscovererDelegate` protocol:

``` swift
func discoverer(_ discoverer: EosConsoleDiscoverer, didFindConsole console: EosConsole) {
    print(console.name)
}

func discoverer(_ discoverer: EosConsoleDiscoverer, didLoseConsole console: EosConsole) {
    print(console.name)
}
```

#### Semi Automatic (UDP Unicast)

If you don't want to automatically discover Eos consoles or in the likely instances that broadcasted packets are dropped by managed switches, you can discover an Eos console via unicast if you have an IP address.

Create the `EosFinder`:

``` swift
let hostIPAddress = "10.101.93.101"
let finder = EosFinder()
finder.delegate = self
finder.find(host: hostIPAddress)
```

Conform to the `EosConsoleDiscovererDelegate` protocol:

``` swift
func discoverer(_ discoverer: EosConsoleDiscoverer, didFindConsole console: EosConsole) {
    print(console.name)
}

func discoverer(_ discoverer: EosConsoleDiscoverer, didLoseConsole console: EosConsole) {
    print(console.name)
}
```

#### Manually (No Discovery)

An `EosConsole` can be created and used without any discovery involved. So long as you can provide a name and a consoles IP address:

Create the `EosConsole`:

``` swift
let console = EosConsole(name: "Sammys Eos Console", host: "10.101.93.101")
```
