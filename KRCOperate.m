//
//  KRCOperate.m
//  testKRC
//
//  Created by jack on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "KRCOperate.h"
#import "zlib.h"

@implementation KRCOperate
static KRCOperate* static_core = nil;

+ (id)currentKRCOperate
{
    @synchronized(self)
    {
        if(static_core == nil)
        {
            static_core = [[KRCOperate alloc] init];
        }
        return static_core;
    }
}

/*
 {
 File krcfile = new File(filenm);
 byte[] zip_byte = new byte[(int) krcfile.length()];
 FileInputStream fileinstrm = new FileInputStream(krcfile);
 byte[] top = new byte[4];
 fileinstrm.read(top);
 fileinstrm.read(zip_byte);
 int j = zip_byte.length;
 for (int k = 0; k < j; k++)
 {
 int l = k % 16;
 int tmp67_65 = k;
 byte[] tmp67_64 = zip_byte;
 tmp67_64[tmp67_65] = (byte) (tmp67_64[tmp67_65] ^ miarry[l]);
 }
 String krc_text = new String(ZLibUtils.decompress(zip_byte), "utf-8");
 return krc_text;
 }
 */

static char miarry[16] = {64, 71, 97, 119, 94, 50, 116, 71, 81, 54, 49, 45, -50, -46, 110, 105};

- (void)test
{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"jay" ofType:@"krc"];
    NSString* savePath = [[NSHomeDirectory()stringByAppendingPathComponent:@"Documents"]stringByAppendingPathComponent:@"save"];
    NSString* writePath = [[NSHomeDirectory()stringByAppendingPathComponent:@"Documents"]stringByAppendingPathComponent:@"write"];
    
    NSData* data = [[NSData alloc] initWithContentsOfFile:path];
    
    NSUInteger length = data.length;
    
    const char* p = data.bytes;
    p = p + 4;
    
    char content[length];
    memset(content, 0, length*sizeof(char));
    memcpy(content, p, length);
    for (int k = 0; k < length; k++)
    {
        int l = k % 16;
        int tmp67_65 = k;
        char* tmp67_64 = content;
        tmp67_64[tmp67_65] = (char) (tmp67_64[tmp67_65] ^ miarry[l]);
    }
    
    NSString* t = @"";
    for(int i=0;i<length;i++)
    {
        t = [t stringByAppendingFormat:@"%d\n", content[i]];
    }
    
    NSLog(@"%@", t);
    
    NSData* tmp = [[NSData alloc] initWithBytes:content length:length];
    [tmp writeToFile:savePath atomically:NO];
    
    //char dest[length*100];
    //memset(dest, 0, length*100*sizeof(char));
    //NSUInteger destLength = 0;
    //int uncompressRet = uncompress(dest, &destLength, (Byte*)content, length);
    
    #define CHUNK 16384
    unsigned char in[CHUNK];
    unsigned char out[CHUNK];
    
    FILE* source = fopen([savePath UTF8String], "r+");
    FILE* dest = fopen([writePath UTF8String], "w+");
    
    z_stream stream;
    memset(&stream, 0, sizeof(z_stream));
    int zlib_ret = inflateInit(&stream);
    if(zlib_ret != Z_OK)
    {
        return;
    }
    int ret;
    unsigned have;
    
    do
    {
        stream.avail_in = fread(in,1,CHUNK,source);
        if (ferror(source))
        {
            (void)inflateEnd(&stream);
        }
        if (0 == stream.avail_in)
            break;
        stream.next_in = in;
        do
        {
            stream.avail_out = CHUNK;
            stream.next_out = out;
            
            ret = inflate(&stream, Z_NO_FLUSH);
            switch(ret)
            {
                case Z_NEED_DICT:
                    ret = Z_DATA_ERROR;
                case Z_DATA_ERROR:
                case Z_MEM_ERROR:
                    (void)inflateEnd(&stream);
            }
            have = CHUNK - stream.avail_out;
            if (fwrite(out,1,have,dest) != have || ferror(dest))
            {
                (void)inflateEnd(&stream);
            }
        }while (stream.avail_out == 0);
    }while(ret != Z_STREAM_END);
    (void)inflateEnd(&stream);
    
    
    fclose(source);
    fclose(dest);
    //NSData* ret = tmp;
    
    //NSString* str = [[NSString alloc] initWithData:ret encoding:NSUTF8StringEncoding];
    
    //NSLog(@"str:%@", str);
    
    NSString* fileSuccess = [[NSString alloc] initWithContentsOfFile:writePath encoding:NSUTF8StringEncoding error:nil];
    
    NSLog(@"su:%@", fileSuccess);
}

@end
