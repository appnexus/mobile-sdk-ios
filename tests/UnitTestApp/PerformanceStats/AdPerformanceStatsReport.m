/*   Copyright 2020 APPNEXUS INC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/



#import <XCTest/XCTest.h>
#import "ANTimeTracker.h"
#import "ANGlobal.h"
#import "XandrAd.h"
@interface AdPerformanceStatsReport : XCTestCase

@end

@implementation AdPerformanceStatsReport

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    // Init here if not the tests will crash
    [[XandrAd sharedInstance] initWithMemberID:1 preCacheRequestObjects:true completionHandler:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testReportBuild {
    
    NSArray *adType = @[BANNER,BANNERNATIVERENDERER,BANNERNATIVE,BANNERVIDEO,INTERSTITIAL,MAR,VIDEO,NATIVE];
    NSArray *adTestcase = @[@[PERFORMANCESTATSRTBAD_FIRST_REQUEST, PERFORMANCESTATSRTBAD_FIRST_WEBVIEW_REQUEST, PERFORMANCESTATSRTBAD_FIRST_NETWORK_REQUEST],
                            @[PERFORMANCESTATSRTBAD_SECOND_REQUEST, PERFORMANCESTATSRTBAD_SECOND_WEBVIEW_REQUEST, PERFORMANCESTATSRTBAD_SECOND_NETWORK_REQUEST]
    ];
    
    NSString *html = [NSString stringWithFormat: @"<!DOCTYPE html> <html> <head> <style> table { font-family: arial, sans-serif; border-collapse: collapse; width: 100%; } td, th { border: 1px solid #dddddd; text-align: left; padding: 8px; } tr:nth-child(even) { background-color: #dddddd; } </style> </head> <body><U><B><h1>Performance Stats Report  SDK Version %@</h1></B></U>", AN_SDK_VERSION];
    
    for (int k = 0; k<adType.count ; k++){
        
        NSString *adTypeValue = adType[k];
        NSString *header  = [NSString stringWithFormat:@"<U><B><h2>%@ AD</h2></B></U>",adTypeValue.uppercaseString ];
        html  = [NSString stringWithFormat:@"%@%@",html,header];
        
        for (int i = 0; i<adTestcase.count ; i++){
            
            NSString *order  = [NSString stringWithFormat:@"<h3>Load %d </h3>", i+1];
            html  = [NSString stringWithFormat:@"%@%@",html,order];
            
            
            NSString *tableColumnOpen  = [NSString stringWithFormat:@"<table style='width:100%' border='1'> <tr> <th>Load Order</th> <th>Date Time</th> <th>Total Ad Load Time</th> <th>WebView Request </th> <th>Network</th></tr>"];
            
            html  = [NSString stringWithFormat:@"%@%@",html,tableColumnOpen];
            
            NSString *adLoad = [NSString stringWithFormat:@"%@%@",adType[k], adTestcase[i][0]];
            NSString *webview = [NSString stringWithFormat:@"%@%@",adType[k], adTestcase[i][1]];
            NSString *network = [NSString stringWithFormat:@"%@%@",adType[k], adTestcase[i][2]];
            
            NSArray *adTypeData =  [ANTimeTracker getData:adLoad];
            NSArray *webviewData =  [ANTimeTracker getData:webview];
            NSArray *networkData =  [ANTimeTracker getData:network];
            NSMutableArray *allAdType = [[NSMutableArray alloc] init];
            NSMutableArray *allWebView = [[NSMutableArray alloc] init];
            NSMutableArray *allNetwork = [[NSMutableArray alloc] init];
            
            for (int j = 0; j<adTypeData.count ; j++){
                NSDictionary *adTypeDataAtIndex =  adTypeData[j];
                NSDictionary *webviewDataAtIndex;
                NSDictionary *networkDataAtIndex;

                
                if( adTypeData.count <= webviewData.count)
                {
                    webviewDataAtIndex  = webviewData[j];
                }
                
                if( adTypeData.count <= networkData.count){
                    networkDataAtIndex  =  networkData[j];
                }
                
                NSString *adloadDate  = adTypeDataAtIndex[@"date"];
                NSString *adloadLoadTime  = adTypeDataAtIndex[@"loadTime"];
                NSString *webviewLoadTime  = (webviewDataAtIndex[@"loadTime"] != NULL) ? webviewDataAtIndex[@"loadTime"] : @"";
                NSString *networkLoadTime  =(networkDataAtIndex[@"loadTime"] != NULL) ? networkDataAtIndex[@"loadTime"] : @"";
                
                
                double currentAdLoad =[adloadLoadTime doubleValue];
                double currentWebviewLoad =[webviewLoadTime doubleValue];
                double currentnetworkLoad =[networkLoadTime doubleValue];
                
                [allAdType addObject:[NSNumber numberWithDouble:currentAdLoad]];
                if([adTypeValue isEqualToString:NATIVE] || [adTypeValue isEqualToString:MAR]|| [adTypeValue isEqualToString:BANNERNATIVE]){
                    webviewLoadTime = @"NA";
                }
                [allWebView addObject:[NSNumber numberWithDouble:currentWebviewLoad]];
                
                [allNetwork addObject:[NSNumber numberWithDouble:currentnetworkLoad]];
                
                NSString *tableRow  = [NSString stringWithFormat:@"<tr> <td>%d</td> <td>%@</td> <td>%@</td> <td>%@</td> <td>%@</td> </tr>",j+1,adloadDate,adloadLoadTime,webviewLoadTime,networkLoadTime];
                html  = [NSString stringWithFormat:@"%@%@",html,tableRow];
            }
            
            NSNumber * maxAdType = [allAdType valueForKeyPath:@"@max.doubleValue"];
            NSNumber * maxWebView = [allWebView valueForKeyPath:@"@max.doubleValue"];
            NSNumber * maxNetwork = [allNetwork valueForKeyPath:@"@max.doubleValue"];
            NSNumber * minAdType = [allAdType valueForKeyPath:@"@min.doubleValue"];
            NSNumber * minWebView = [allWebView valueForKeyPath:@"@min.doubleValue"];
            NSNumber * minNetwork = [allNetwork valueForKeyPath:@"@min.doubleValue"];
            NSNumber * avgAdType = [allAdType valueForKeyPath:@"@avg.doubleValue"];
            NSNumber * avgWebView = [allWebView valueForKeyPath:@"@avg.doubleValue"];
            NSNumber * avgNetwork = [allNetwork valueForKeyPath:@"@avg.doubleValue"];
            
            if([adTypeValue isEqualToString:NATIVE] || [adTypeValue isEqualToString:MAR]|| [adTypeValue isEqualToString:BANNERNATIVE]){
                maxWebView = 0;
                minWebView = 0;
                avgWebView = 0;
            }
            NSString *tableRowMax  = [NSString stringWithFormat:@"<tr> <td>Maximum</td> <td></td> <td>%.2f</td> <td>%.2f</td> <td>%.2f</td> </tr>",[maxAdType doubleValue],[maxWebView doubleValue],[maxNetwork doubleValue]];
            html  = [NSString stringWithFormat:@"%@%@",html,tableRowMax];
            
            NSString *tableRowMin  = [NSString stringWithFormat:@"<tr> <td>Minimum</td> <td></td> <td>%.2f</td> <td>%.2f</td> <td>%.2f</td> </tr>",[minAdType doubleValue],[minWebView doubleValue],[minNetwork doubleValue]];
            html  = [NSString stringWithFormat:@"%@%@",html,tableRowMin];
            
            NSString *tableRowAvg  = [NSString stringWithFormat:@"<tr> <td>Average</td> <td></td> <td>%.2f</td> <td>%.2f</td> <td>%.2f</td> </tr>",[avgAdType doubleValue],[avgWebView doubleValue],[avgNetwork doubleValue]];
            html  = [NSString stringWithFormat:@"%@%@",html,tableRowAvg];
            
            NSString *tableColumnClose  = [NSString stringWithFormat:@"</table></body></html>"];
            html  = [NSString stringWithFormat:@"%@%@",html,tableColumnClose];
            
        }
    }
    
    
    NSFileManager *fileManager= [NSFileManager defaultManager];
    NSError *error = nil;
    if([fileManager createDirectoryAtPath:@"Users/Shared/PerformanceStats" withIntermediateDirectories:YES attributes:nil error:&error]) {
        NSString *fileName = [NSString stringWithFormat:@"Users/Shared/PerformanceStats/Report SDK-v%@.html",AN_SDK_VERSION];
        [html writeToFile:fileName atomically:YES encoding: NSUTF8StringEncoding error:nil];
        NSLog(@"Html File Path  =  %@",fileName);
    }
}


@end
