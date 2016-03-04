//
//  HJBluetoothManager.h
//  HJBluetooth
//
//  Created by hj on 15/8/10.
//  Copyright © 2015年 hj. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


@interface HJBluetoothManager : NSObject

typedef void (^HJCentralUpdateStateBlock)(HJBluetoothManager *manager);
typedef void (^HJScanBlock)(NSArray *array);
typedef void (^HJSuccessConnectPeripheralBlock)(CBPeripheral *peripheral);
typedef void (^HJFailConnectPeripheralBlock)(CBPeripheral *peripheral,NSError *error);
typedef void (^HJDisConnectPeripheralBlock)(CBPeripheral *peripheral ,NSError *error);
typedef void (^HJDiscoverServicesBlock)(CBPeripheral *peripheral ,NSError *error);
typedef void (^HJDiscoverCharacteristicsBlock)(CBPeripheral *peripheral,CBService *service ,NSError *error);
typedef void (^HJReadValueBlock)(CBCharacteristic *characteristic, NSError *error);
typedef void (^HJWriteValueBlock)(CBCharacteristic *characteristic, NSError *error);


@property (nonatomic, strong)CBCentralManager *centralManager;
@property (nonatomic, copy) HJCentralUpdateStateBlock  updateStateBlock;
@property (nonatomic, copy) HJDiscoverServicesBlock  servicesBlock;
@property (nonatomic, copy) HJDiscoverCharacteristicsBlock characteristicsBlock;
@property (nonatomic, copy) HJReadValueBlock  readValueBlock;


+ (HJBluetoothManager *)shareIntance;

- (void)scanPeripehralsWithBlock:(HJScanBlock)block;

- (void)stopScan;

- (void)connectPeripheral:(CBPeripheral *)peripheral successBlock:(HJSuccessConnectPeripheralBlock)sucessBlock failBlock:(HJFailConnectPeripheralBlock)failBlock;

- (void)disConnectPeripheralWithBlock:(HJDisConnectPeripheralBlock)block;

- (void)writeValueWithData:(NSData *)data characteristic:(CBCharacteristic *)writeCharacteristic block:(HJWriteValueBlock)block;

@end
