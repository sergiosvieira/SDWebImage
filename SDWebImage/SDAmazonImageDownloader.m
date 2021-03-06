//
//  SDAmazonImageDownloader.m
//  Wello
//
//  Created by Paulo Pinheiro on 5/3/13.
//  Copyright (c) 2013 Wello Corp. All rights reserved.
//

#import "SDAmazonImageDownloader.h"
//#import <AWSiOSSDK/S3/AmazonS3Client.h>
//#import <AWSiOSSDK/AmazonServiceRequest.h>


@interface SDAmazonImageDownloader ()
@property (strong, nonatomic) NSMutableDictionary *completedBlocks;
@end

@implementation SDAmazonImageDownloader

- (AmazonS3Client *)s3Client
{
    if (!_s3Client)
    {
        _s3Client = [[AmazonS3Client alloc] initWithAccessKey:self.accessKey withSecretKey:self.secretKey];
    }
    
    return _s3Client;
}

- (NSMutableDictionary *)completedBlocks
{
    if (!_completedBlocks)
    {
        _completedBlocks = [[NSMutableDictionary alloc] init];
    }
    
    return _completedBlocks;
}

#pragma mark - Init
- (id)initWithAccessKey:(NSString *)accessKey withSecretKey:secretKey
{
    self = [super init];
    
    if (self)
    {
        self.accessKey = accessKey;
        self.secretKey = secretKey;
    }
    
    return self;
}

#pragma mark - Public Methods
- (void)downloadWithBucket:(NSString *)bucket withFilename:(NSString *)filename completed:
    (SDAmazonImageDownloaderCompletedBlock)completedBlock
{
    
    S3GetObjectRequest  *request;
    S3GetObjectResponse *response;

    request = [[S3GetObjectRequest alloc] initWithKey:filename withBucket:bucket];
    [request setDelegate:self];
    response = [self.s3Client getObject:request];

    if (response.error != nil)
    {
        NSLog(@"Error:%@", response.error);
    }
    
    self.completedBlocks[@(request.hash)] = completedBlock;
}

#pragma mark - AmazonServiceRequestDelegate
- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response
{    
    UIImage *image = [UIImage imageWithData:response.body];
    S3GetObjectRequest *amazonRequest = (S3GetObjectRequest *)request;
    SDAmazonImageDownloaderCompletedBlock block = self.completedBlocks[@(amazonRequest.hash)];
    
    NSMutableString *key = [[request.url path] mutableCopy];
    
    [key deleteCharactersInRange:NSMakeRange(0, 1)];
    
    if (block)
    {
        block([key copy], image, response.error);
        
        [self.completedBlocks removeObjectForKey:@(amazonRequest.hash)];
    }
}

@end
