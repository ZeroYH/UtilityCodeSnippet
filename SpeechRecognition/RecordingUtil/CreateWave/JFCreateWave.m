//
//  JFCreateWave.m
//  ChatComps
//
//  Created by StarLord on 2018/9/14.
//  Copyright © 2018年 Javor Feng. All rights reserved.
//

#import "JFCreateWave.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "Constant.h"

#define absX(x) (x<0?0-x:x)
#define minMaxX(x,mn,mx) (x<=mn?mn:(x>=mx?mx:x))
#define noiseFloor (-50.0)
#define decibel(amplitude) (20.0 * log10(absX(amplitude)/32767.0))
#define imgExt @"png"
#define imageToData(x) UIImagePNGRepresentation(x)
#define targetOverDraw 3 // Will make image that is more pixels than screen can show
#define minimumOverDraw 2
#define plotChannelOneColor [[UIColor whiteColor] CGColor]

@interface JFCreateWave ()

//@property (nonatomic, strong) AVURLAsset        *asset;
//@property (nonatomic, assign) unsigned long int totalSamples; // 总长度


@end

@implementation JFCreateWave

+ (void)createWaveWithAudioURL:(NSURL *)audioURL size:(CGSize)size message:(IMStructMessage *)currentMessage waveImage:(void(^)(UIImage *image, IMStructMessage *currentMessage))waveImage {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:audioURL options:nil];
        unsigned long int totalSamples = (unsigned long int)asset.duration.value;
        if (totalSamples != 0) {
            UIImage *image = [self renderPNGAudioPictogramLogForAsset:asset size:size totalSamples:totalSamples];
            dispatch_async(dispatch_get_main_queue(), ^{
                !waveImage?:waveImage(image, currentMessage);
            });
        }
    });
}

+ (UIImage *)renderPNGAudioPictogramLogForAsset:(AVURLAsset *)songAsset size:(CGSize)size totalSamples:(unsigned long int)totalSamples {
    // TODO: break out subsampling code
    CGFloat widthInPixels = size.width * [UIScreen mainScreen].scale * targetOverDraw;
    CGFloat heightInPixels = size.height * [UIScreen mainScreen].scale;
    
    NSError *error = nil;
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:songAsset error:&error];
    if (songAsset.tracks.count == 0) {
        return nil;
    }
    AVAssetTrack *songTrack = [songAsset.tracks objectAtIndex:0];
    NSDictionary *outputSettingsDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                                        [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsNonInterleaved,
                                        nil];
    AVAssetReaderTrackOutput *output = [[AVAssetReaderTrackOutput alloc] initWithTrack:songTrack outputSettings:outputSettingsDict];
    [reader addOutput:output];
    UInt32 channelCount;
    NSArray *formatDesc = songTrack.formatDescriptions;
    for(unsigned int i = 0; i < [formatDesc count]; ++i) {
        CMAudioFormatDescriptionRef item = (__bridge CMAudioFormatDescriptionRef)[formatDesc objectAtIndex:i];
        const AudioStreamBasicDescription* fmtDesc = CMAudioFormatDescriptionGetStreamBasicDescription(item);
        if (!fmtDesc) return nil; //!
        channelCount = fmtDesc->mChannelsPerFrame;
    }
    
    UInt32 bytesPerInputSample = 2 * channelCount;
    Float32 maximum = noiseFloor;
    Float64 tally = 0;
    Float32 tallyCount = 0;
    Float32 outSamples = 0;
    NSInteger downsampleFactor = totalSamples / widthInPixels;
    downsampleFactor = downsampleFactor<1 ? 1 : downsampleFactor;
    NSMutableData *fullSongData = [[NSMutableData alloc] initWithCapacity:totalSamples/downsampleFactor*2]; // 16-bit samples
    [reader startReading];
    
    while (reader.status == AVAssetReaderStatusReading) {
        AVAssetReaderTrackOutput * trackOutput = (AVAssetReaderTrackOutput *)[reader.outputs objectAtIndex:0];
        CMSampleBufferRef sampleBufferRef = [trackOutput copyNextSampleBuffer];
        if (sampleBufferRef) {
            CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBufferRef);
            size_t bufferLength = CMBlockBufferGetDataLength(blockBufferRef);
            void *data = malloc(bufferLength);
            CMBlockBufferCopyDataBytes(blockBufferRef, 0, bufferLength, data);
            
            SInt16 *samples = (SInt16 *)data;
            int sampleCount = bufferLength / bytesPerInputSample;
            for (int i=0; i<sampleCount; i++) {
                Float32 sample = (Float32) *samples++;
                sample = decibel(sample);
                sample = minMaxX(sample,noiseFloor,0);
                tally += sample; // Should be RMS?
                for (int j=1; j<channelCount; j++)
                    samples++;
                tallyCount++;
                
                if (tallyCount == downsampleFactor) {
                    sample = tally / tallyCount;
                    maximum = maximum > sample ? maximum : sample;
                    [fullSongData appendBytes:&sample length:sizeof(sample)];
                    tally = 0;
                    tallyCount = 0;
                    outSamples++;
                }
            }
            CMSampleBufferInvalidate(sampleBufferRef);
            CFRelease(sampleBufferRef);
            free(data);
        }
    }
    if (reader.status == AVAssetReaderStatusCompleted){
        Log(@"JWaveFormView: start rendering PNG W= %f", outSamples);
        UIImage *waveImage = [self plotLogGraph:(Float32 *)fullSongData.bytes maximumValue:maximum mimimumValue:noiseFloor sampleCount:outSamples imageHeight:heightInPixels];
        return waveImage;
    }
    return nil;
}

+ (UIImage *)plotLogGraph:(Float32 *) samples maximumValue:(Float32) normalizeMax mimimumValue:(Float32) normalizeMin sampleCount:(NSInteger) sampleCount imageHeight:(float) imageHeight {
    // TODO: switch to a synchronous function that paints onto a given context
    CGSize imageSize = CGSizeMake(sampleCount, imageHeight);
    UIGraphicsBeginImageContext(imageSize); // this is leaking memory?
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAlpha(context,1.0);
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, plotChannelOneColor);
    
    float halfGraphHeight = (imageHeight / 2);
    float centerLeft = halfGraphHeight;
    float sampleAdjustmentFactor = imageHeight / (normalizeMax - noiseFloor) / 2;
    
    for (NSInteger intSample=0; intSample<sampleCount; intSample++) {
        Float32 sample = *samples++;
        float pixels = (sample - noiseFloor) * sampleAdjustmentFactor;
        CGContextMoveToPoint(context, intSample, centerLeft-pixels);
        CGContextAddLineToPoint(context, intSample, centerLeft+pixels);
        CGContextStrokePath(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsBeginImageContext(image.size);
    CGRect drawRect = CGRectMake(0, 0, image.size.width, image.size.height);
    [image drawInRect:drawRect];
    UIGraphicsEndImageContext();
    Log(@"JWaveFormView: done rendering PNG W=%f H=%f", image.size.width, image.size.height);
    return image;
}


@end
