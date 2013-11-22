//
//  SDAmazonImageDownloader.h
//  Wello
//
//  Created by Paulo Pinheiro on 5/3/13.
//  Copyright (c) 2013 Wello Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSRuntime/AmazonServiceRequest.h>

typedef void(^SDAmazonImageDownloaderCompletedBlock)(NSString *key, UIImage *image, NSError *error);


@class AmazonS3Client;

@protocol AmazonServiceRequestDelegate;

@interface SDAmazonImageDownloader : NSObject
<
    AmazonServiceRequestDelegate
>

#pragma mark - Init
- (id)initWithAccessKey:(NSString *)accessKey withSecretKey:secretKey;

#pragma mark - Public Methods
- (void)downloadWithBucket:(NSString *)bucket withFilename:(NSString *)filename completed:
    (SDAmazonImageDownloaderCompletedBlock)completedBlock;

#pragma mark - Lazy Properties
@property (strong, nonatomic)AmazonS3Client *s3Client;

#pragma mark - Properties
@property (strong, nonatomic) NSString *accessKey;
@property (strong, nonatomic) NSString *secretKey;

@end
