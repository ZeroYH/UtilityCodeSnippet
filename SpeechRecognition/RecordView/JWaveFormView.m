//
//  JWaveFormView.m
//  ChatComps
//
//  Created by Sunjimin on 2018/9/11.
//  Copyright © 2018年 Javor Feng. All rights reserved.
//

#import "JWaveFormView.h"

#define absX(x) (x<0?0-x:x)
#define minMaxX(x,mn,mx) (x<=mn?mn:(x>=mx?mx:x))
#define noiseFloor (-50.0)
#define decibel(amplitude) (20.0 * log10(absX(amplitude)/32767.0))
#define imgExt @"png"
#define imageToData(x) UIImagePNGRepresentation(x)
#define targetOverDraw 3 // Will make image that is more pixels than screen can show
#define minimumOverDraw 2


@interface JWaveFormView ()

@property (nonatomic, strong) UIImageView       *highlightedImage;      /// 已播放的音频图（高亮）
@property (nonatomic, strong) UIView            *clipping;
@property (nonatomic, strong) AVURLAsset        *asset;
@property (nonatomic, assign) unsigned long int totalSamples;
@property (nonatomic, assign) unsigned long int cachedStartSamples;
@property (nonatomic, assign) unsigned long int cachedEndSamples;

@end

@implementation JWaveFormView

- (void)initialize {
    self.image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.highlightedImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.image.contentMode = UIViewContentModeScaleToFill;
    self.highlightedImage.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:self.image];
    self.clipping = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.clipping addSubview:self.highlightedImage];
    self.clipping.clipsToBounds = YES;
    [self addSubview:self.clipping];
}

- (id)initWithCoder:(NSCoder *)aCoder {
    if (self = [super initWithCoder:aCoder])
        [self initialize];
    return self;
}

- (id)initWithFrame:(CGRect)rect {
    if (self = [super initWithFrame:rect])
        [self initialize];
    return self;
}

- (void)setAudioURL:(NSURL *)audioURL {
    _audioURL = audioURL;
    self.asset = [AVURLAsset URLAssetWithURL:audioURL options:nil];
    self.image.image = nil;
    self.highlightedImage.image = nil;
    self.totalSamples = (unsigned long int) self.asset.duration.value;
    _progressSamples = 0; // skip setter
    if (self.totalSamples != 0) {    
        [self setNeedsDisplay];
    }
}

- (void)setProgressSamples:(unsigned long)progressSamples {
    if (self.totalSamples != 0) {
        _progressSamples = progressSamples;
        float progress = (float)self.progressSamples / self.totalSamples;
        self.clipping.frame = CGRectMake(0,0,self.frame.size.width*progress,self.frame.size.height);
        [self setNeedsLayout];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.doesAllowScrubbing)
        return;
    UITouch *touch = [touches anyObject];
    self.progressSamples = (float)self.totalSamples * [touch locationInView:self].x / self.bounds.size.width;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.doesAllowScrubbing)
        return;
    UITouch *touch = [touches anyObject];
    self.progressSamples = (float)self.totalSamples * [touch locationInView:self].x / self.bounds.size.width;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.layer.contents) {
        return;
    }
    
    float progress = self.totalSamples ? (float)self.progressSamples / self.totalSamples : 0;
    self.image.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.highlightedImage.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.clipping.frame = CGRectMake(0,0,self.frame.size.width*progress,self.frame.size.height);
//    self.clipping.frame = CGRectMake(self.frame.size.width*progress,0,10,self.frame.size.height);
    
    CGFloat neededWidthInPixels = self.frame.size.width * [UIScreen mainScreen].scale * minimumOverDraw;
    CGFloat neededHeightInPixels = self.frame.size.height * [UIScreen mainScreen].scale;
    if (self.asset && (neededWidthInPixels > self.image.image.size.width || neededHeightInPixels > self.image.image.size.height)) {
        NSLog(@"JWaveFormView: rendering, need %d x %d, have %d x %d",
              (int)neededWidthInPixels,
              (int)neededHeightInPixels,
              (int)self.image.image.size.width,
              (int)self.image.image.size.height);
        [self renderPNGAudioPictogramLogForAsset:self.asset
                                            done:^(UIImage *image, UIImage *selectedImage) {
                                                self.image.image = image;
                                                self.highlightedImage.image = selectedImage;
                                            }];
    }
}

#define plotChannelOneColor [[UIColor whiteColor] CGColor]
- (void) plotLogGraph:(Float32 *) samples
         maximumValue:(Float32) normalizeMax
         mimimumValue:(Float32) normalizeMin
          sampleCount:(NSInteger) sampleCount
          imageHeight:(float) imageHeight
                 done:(void(^)(UIImage *image, UIImage *selectedImage))done {
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
    [[UIColor redColor] set];
    UIRectFillUsingBlendMode(drawRect, kCGBlendModeSourceAtop);
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSLog(@"JWaveFormView: done rendering PNG W=%f H=%f", image.size.width, image.size.height);
    !_waveImage?:_waveImage(image , tintedImage);
    done(image, tintedImage);
}

- (void)renderPNGAudioPictogramLogForAsset:(AVURLAsset *)songAsset
                                      done:(void(^)(UIImage *image, UIImage *selectedImage))done {
    // TODO: break out subsampling code
    CGFloat widthInPixels = self.frame.size.width * [UIScreen mainScreen].scale * targetOverDraw;
    CGFloat heightInPixels = self.frame.size.height * [UIScreen mainScreen].scale;
    
    NSError *error = nil;
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:songAsset error:&error];
    if (songAsset.tracks.count == 0) {
        return;
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
        if (!fmtDesc) return; //!
        channelCount = fmtDesc->mChannelsPerFrame;
    }
    
    UInt32 bytesPerInputSample = 2 * channelCount;
    Float32 maximum = noiseFloor;
    Float64 tally = 0;
    Float32 tallyCount = 0;
    Float32 outSamples = 0;
    NSInteger downsampleFactor = self.totalSamples / widthInPixels;
    downsampleFactor = downsampleFactor<1 ? 1 : downsampleFactor;
    NSMutableData *fullSongData = [[NSMutableData alloc] initWithCapacity:self.totalSamples/downsampleFactor*2]; // 16-bit samples
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
        NSLog(@"JWaveFormView: start rendering PNG W= %f", outSamples);
        [self plotLogGraph:(Float32 *)fullSongData.bytes
              maximumValue:maximum
              mimimumValue:noiseFloor
               sampleCount:outSamples
               imageHeight:heightInPixels
                      done:done];
    }
}


@end
