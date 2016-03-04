//
//  HJBluetoothManager.m
//  HJBluetooth
//
//  Created by hj on 15/8/10.
//  Copyright © 2015年 hj. All rights reserved.
//

#import "HJBluetoothManager.h"

@interface HJBluetoothManager () <CBCentralManagerDelegate, CBPeripheralDelegate>
{
    HJScanBlock _scanBlock;
    HJSuccessConnectPeripheralBlock _sucessConnectBlock;
    HJFailConnectPeripheralBlock  _failConnectBlock;
    HJDisConnectPeripheralBlock _disConnectBlock;
    HJWriteValueBlock          _writeValueBlock;
}

@property (strong,nonatomic)NSMutableArray *peripheralArray;
@property (nonatomic, strong) CBPeripheral *peripheral;

@end

@implementation HJBluetoothManager

+ (HJBluetoothManager *)shareIntance
{
    static HJBluetoothManager  *bluetoothIntance = nil;
    static  dispatch_once_t once;
    dispatch_once(&once, ^{
        bluetoothIntance = [[HJBluetoothManager alloc] init];
    });
    
    return bluetoothIntance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _peripheralArray = [[NSMutableArray alloc] init];
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    }
    return self;  
}

- (void)scanPeripehralsWithBlock:(HJScanBlock)block;
{
  //[self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"6e400001-b5a3-f393-e0a9-e50e24dcca9e"]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey: [NSNumber numberWithBool:NO]}];
    
    _scanBlock = block;
    [_peripheralArray removeAllObjects];
    [self.centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
}

- (void)stopScan
{
    [self.centralManager cancelPeripheralConnection:_peripheral];
}

- (void)connectPeripheral:(CBPeripheral *)peripheral successBlock:(HJSuccessConnectPeripheralBlock)sucessBlock failBlock:(HJFailConnectPeripheralBlock)failBlock
{
    [self.centralManager stopScan];
    _sucessConnectBlock = sucessBlock;
    _failConnectBlock = failBlock;
    [self.centralManager connectPeripheral:peripheral options:nil];
}

- (void)disConnectPeripheralWithBlock:(HJDisConnectPeripheralBlock)block
{
    _disConnectBlock = block;
    [self.centralManager cancelPeripheralConnection:_peripheral];
}

- (void)writeValueWithData:(NSData *)data characteristic:(CBCharacteristic *)writeCharacteristic block:(HJWriteValueBlock)block
{
    _writeValueBlock = block;
    if (data && writeCharacteristic) {
        [_peripheral writeValue:data forCharacteristic:writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

#pragma mark -CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (_updateStateBlock) {
        _updateStateBlock(self);
    }
}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    
}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals;
{
    
}
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
{
    BOOL replace = NO;
    for (int i=0; i < self.peripheralArray.count; i++) {
        CBPeripheral *p = [self.peripheralArray objectAtIndex:i];
        if ([p isEqual:peripheral]) {
            [self.peripheralArray  replaceObjectAtIndex:i withObject:peripheral];
            replace = YES;
        }
    }
    if (!replace) {
        [self.peripheralArray addObject:peripheral];
    }
    // NSLog(@"peripheral =%@---UUID=%@－－RSSI＝%d",peripheral,peripheral.name,[RSSI intValue]);

    if (_scanBlock) {
        _scanBlock(self.peripheralArray);
    }
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;
{
    _peripheral = peripheral;
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
    if (_sucessConnectBlock) {
        _sucessConnectBlock(peripheral);
    }
}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
{
    if (_failConnectBlock) {
        _failConnectBlock(peripheral,error);
    }
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
{
    if (_disConnectBlock) {
        _disConnectBlock(peripheral,error);
    }
}

#pragma mark- CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (_servicesBlock) {
        _servicesBlock(peripheral,error);
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error;
{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
{
    if (_characteristicsBlock) {
        _characteristicsBlock(peripheral,service,error);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (_readValueBlock) {
        _readValueBlock(characteristic,error);
    }
}
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"发送数据失败：%@",error.userInfo);
    }else{      
        NSLog(@"发送数据成功");
    }
    
    if (_writeValueBlock) {
        _writeValueBlock(characteristic,error);
    }
}

@end
