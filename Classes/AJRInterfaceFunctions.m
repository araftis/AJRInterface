
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
    return [NSBundle bundleWithIdentifier:@"com.ajr.framework.interface"];
}
