//
//  JFPcmConversionAmr.m
//  ChatComps
//
//  Created by StarLord on 2018/9/11.
//  Copyright © 2018年 Javor Feng. All rights reserved.
//

#import "JFPcmConversionAmr.h"
#import "VoiceConverter.h"
#import "Constant.h"
#import "JFSpeechRecognitionConstant.h"

@implementation JFPcmConversionAmr

// 为pcm文件写入wav头
+ (NSData *)writeWavHead:(NSData *)audioData sampleRate:(long)sampleRate {
    Byte waveHead[44];
    waveHead[0] = 'R';
    waveHead[1] = 'I';
    waveHead[2] = 'F';
    waveHead[3] = 'F';
    
    long totalDatalength = [audioData length] + 44;
    waveHead[4] = (Byte)(totalDatalength & 0xff);
    waveHead[5] = (Byte)((totalDatalength >> 8) & 0xff);
    waveHead[6] = (Byte)((totalDatalength >> 16) & 0xff);
    waveHead[7] = (Byte)((totalDatalength >> 24) & 0xff);
    
    waveHead[8] = 'W';
    waveHead[9] = 'A';
    waveHead[10] = 'V';
    waveHead[11] = 'E';
    
    waveHead[12] = 'f';
    waveHead[13] = 'm';
    waveHead[14] = 't';
    waveHead[15] = ' ';
    
    waveHead[16] = 16;  //size of 'fmt '
    waveHead[17] = 0;
    waveHead[18] = 0;
    waveHead[19] = 0;
    
    waveHead[20] = 1;   //format
    waveHead[21] = 0;
    
    waveHead[22] = 1;   //chanel
    waveHead[23] = 0;
    
    waveHead[24] = (Byte)(sampleRate & 0xff);
    waveHead[25] = (Byte)((sampleRate >> 8) & 0xff);
    waveHead[26] = (Byte)((sampleRate >> 16) & 0xff);
    waveHead[27] = (Byte)((sampleRate >> 24) & 0xff);
    
    long byteRate = sampleRate * 2 * (16 >> 3);;
    waveHead[28] = (Byte)(byteRate & 0xff);
    waveHead[29] = (Byte)((byteRate >> 8) & 0xff);
    waveHead[30] = (Byte)((byteRate >> 16) & 0xff);
    waveHead[31] = (Byte)((byteRate >> 24) & 0xff);
    
    waveHead[32] = 2*(16 >> 3);
    waveHead[33] = 0;
    
    waveHead[34] = 16;
    waveHead[35] = 0;
    
    waveHead[36] = 'd';
    waveHead[37] = 'a';
    waveHead[38] = 't';
    waveHead[39] = 'a';
    
    long totalAudiolength = [audioData length];
    
    waveHead[40] = (Byte)(totalAudiolength & 0xff);
    waveHead[41] = (Byte)((totalAudiolength >> 8) & 0xff);
    waveHead[42] = (Byte)((totalAudiolength >> 16) & 0xff);
    waveHead[43] = (Byte)((totalAudiolength >> 24) & 0xff);
    
    NSMutableData *pcmData = [[NSMutableData alloc] initWithBytes:&waveHead length:sizeof(waveHead)];
    [pcmData appendData:audioData];
    return pcmData;
}

+ (BOOL)wavConversionAmrWithWavPath:(NSString *)wavPath amrSavePath:(NSString *)amrSavePath {
    BOOL result = [VoiceConverter EncodeWavToAmr:wavPath amrSavePath:amrSavePath sampleRateType:(Sample_Rate_16000)];
    return result;
}

+ (BOOL)pcmConversionAmrWithpcmData:(NSData *)pcmData sampleRate:(long)sampleRate wavSavePath:(NSString *)wavSavePath amrSavePath:(NSString *)amrSavePath {
    NSData *wavData = [self writeWavHead:pcmData sampleRate:sampleRate];
    [wavData writeToFile:wavSavePath atomically:true];
    BOOL result = [self wavConversionAmrWithWavPath:wavSavePath amrSavePath:amrSavePath];
    return result;
}

+ (BOOL)jfAmrAudioWithPcmAudioRelativePath:(NSString *)audioRelativePath {
    // 转成amr
    BOOL result = [self pcmConversionAmrWithpcmData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", kPath, audioRelativePath]] sampleRate:16000 wavSavePath:[NSString stringWithFormat:@"%@/%@/%@.wav", kPath, [JFSpeechRecognitionConstant speechRecognizerLocalFolderName], [[[[audioRelativePath componentsSeparatedByString:@"/"] lastObject] componentsSeparatedByString:@"."] firstObject]] amrSavePath:[NSString stringWithFormat:@"%@/%@/%@.amr", kPath, [JFSpeechRecognitionConstant speechRecognizerLocalFolderName], [[[[audioRelativePath componentsSeparatedByString:@"/"] lastObject] componentsSeparatedByString:@"."] firstObject]]];
    if (result) {
        // 删除pcm
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@", kPath, audioRelativePath] error:nil];
//        // 删除wav
//        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@/%@.wav", kPath, [JFSpeechRecognitionConstant speechRecognizerLocalFolderName], [[[[audioRelativePath componentsSeparatedByString:@"/"] lastObject] componentsSeparatedByString:@"."] firstObject]] error:nil];
        
    }
    return result;
}

@end
