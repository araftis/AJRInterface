/*
AJRInterfaceFunctions.m
AJRInterface

Copyright © 2021, AJ Raftis and AJRFoundation authors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
* Neither the name of AJRFoundation nor the names of its contributors may be 
  used to endorse or promote products derived from this software without 
  specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <AJRInterface/AJRInterfaceFunctions.h>

NSRect AJRComputeScaledRect(NSRect rect, NSSize naturalSize, NSUInteger mask)
{
    NSRect work;
    
    if (naturalSize.width == 0 || naturalSize.height == 0) {
        work = rect;
    } else {
        if (mask & AJRContentScaledMask) {
            if (mask & AJRContentScaledToFitMask) {
                if (mask & AJRContentScaledPorportional) {
                    float        wScale, hScale;
                    float        wDelta, hDelta;
                    
                    wDelta = rect.size.width - naturalSize.width;
                    hDelta = rect.size.height - naturalSize.height;
                    
                    wScale = rect.size.width / naturalSize.width;
                    hScale = rect.size.height / naturalSize.height;
                    
                    //AJRPrintf(@"wd = %.1f, hd = %.1f, ws = %.4f, hs = %.4f\n", wDelta, hDelta, wScale, hScale);
                    
                    if (wDelta >= 0 && hDelta < 0) {
                        work.size.width = naturalSize.width * hScale;
                        work.size.height = naturalSize.height * hScale;
                    } else if (wDelta < 0 && hDelta >= 0) {
                        work.size.width = naturalSize.width * wScale;
                        work.size.height = naturalSize.height * wScale;
                    } else {
                        work.size.width = naturalSize.width * (wScale > hScale ? hScale : wScale);
                        work.size.height = naturalSize.height * (wScale > hScale ? hScale : wScale);
                    }
                } else {
                    work.size = rect.size;
                }
            } else {
                if (mask & AJRContentScaledPorportional) {
                    float        wScale, hScale;
                    float        wDelta, hDelta;
                    
                    wDelta = rect.size.width - naturalSize.width;
                    hDelta = rect.size.height - naturalSize.height;
                    
                    wScale = rect.size.width / naturalSize.width;
                    hScale = rect.size.height / naturalSize.height;
                    
                    //AJRPrintf(@"wd = %.1f, hd = %.1f, ws = %.4f, hs = %.4f\n", wDelta, hDelta, wScale, hScale);
                    
                    if (wDelta >= 0 && hDelta < 0) {
                        work.size.width = naturalSize.width * hScale;
                        work.size.height = naturalSize.height * hScale;
                    } else if (wDelta < 0 && hDelta >= 0) {
                        work.size.width = naturalSize.width * wScale;
                        work.size.height = naturalSize.height * wScale;
                    } else if (wDelta >= 0 && hDelta >= 0) {
                        work.size = naturalSize;
                    } else {
                        work.size.width = naturalSize.width * (wScale > hScale ? hScale : wScale);
                        work.size.height = naturalSize.height * (wScale > hScale ? hScale : wScale);
                    }
                } else {
                    work.size.width = (naturalSize.width > rect.size.width) ? rect.size.width : naturalSize.width;
                    work.size.height = (naturalSize.height > rect.size.height) ? rect.size.height : naturalSize.height;
                }
            }
        } else {
            work.size = naturalSize;
        }
        work.origin.x = rect.origin.x + (rect.size.width / 2.0 - work.size.width / 2.0);
        work.origin.y = rect.origin.y + (rect.size.height / 2.0 - work.size.height / 2.0);
    }
    
    return work;
}

NSBundle *AJRInterfaceBundle(void) {
    return [NSBundle bundleWithIdentifier:@"com.ajr.framework.AJRInterface"];
}
