/*   Copyright 2013 APPNEXUS INC
 
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

#import "ANBannerAdView.h"
#import "ANAdFetcher.h"
#import "ANAdResponse.h"

@interface ANAdView (ANBannerAdView)
- (void)initialize;
@end

@interface ANBannerAdView ()

@end


@implementation ANBannerAdView
@synthesize delegate = __delegate;
@synthesize autorefreshInterval = __autorefreshInterval;

- (id)init
{
	self = [super init];
	
	if (self != nil)
	{

	}
	
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self != nil)
	{

	}
	
	return self;
}

- (void)initialize
{
	[super initialize];
	
	self.backgroundColor = [UIColor clearColor];
	self.autoresizingMask = UIViewAutoresizingNone;
	
	// Start autorefresh automatically
	__autorefreshInterval = kANBannerAdViewDefaultAutorefreshInterval;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	self.adSize = self.frame.size;
}

+ (ANBannerAdView *)adViewWithFrame:(CGRect)frame placementId:(NSString *)placementId
{
    return [[[self class] alloc] initWithFrame:frame placementId:placementId adSize:frame.size];
}

+ (ANBannerAdView *)adViewWithFrame:(CGRect)frame placementId:(NSString *)placementId adSize:(CGSize)size
{
    return [[[self class] alloc] initWithFrame:frame placementId:placementId adSize:size];
}

- (id)initWithFrame:(CGRect)frame placementId:(NSString *)placementId adSize:(CGSize)size
{
    if (self = [super initWithFrame:frame placementId:placementId adSize:size])
	{
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)loadAd
{
    if (self.autorefreshInterval > 0)
    {
        ANLogWarn(@"Ad view already scheduled to refresh ads every %f seconds", self.autorefreshInterval);
    }
    else
    {
        [self.adFetcher requestAd];
    }
}

- (CGSize)adSize
{
    ANLogDebug(@"adSize returned %@", NSStringFromCGSize(__adSize));
    return __adSize;
}

- (void)setAdSize:(CGSize)adSize
{
    if (!CGSizeEqualToSize(adSize, __adSize))
    {
        ANLogDebug(@"Setting adSize to %@", NSStringFromCGSize(adSize));
        __adSize = adSize;
    }
}

- (NSString *)placementSizeParameter
{
    NSString *placementSizeParameter = @"";
    
    CGSize sizeToRequest = CGSizeEqualToSize(self.adSize, CGSizeZero) ? self.frame.size : self.adSize;
    placementSizeParameter = [NSString stringWithFormat:@"&size=%dx%d", (NSInteger)sizeToRequest.width, (NSInteger)sizeToRequest.height];
    return placementSizeParameter;
}

- (NSString *)maximumSizeParameter
{
    return [NSString stringWithFormat:@"&max-size=%dx%d", (NSInteger)self.frame.size.width, (NSInteger)self.frame.size.height];
}

- (NSString *)adType
{
    return @"inline";
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self.contentView setFrame:self.bounds];
}

- (void)setAutorefreshInterval:(NSTimeInterval)autorefreshInterval
{    
	if (autorefreshInterval < 15.0f && autorefreshInterval > 0.0f)
	{
		ANLogError(@"Cannot set autorefresh interval less than 15 seconds.");
	}
	else if (autorefreshInterval < 0.0f)
	{
		ANLogError(@"Ad view interval cannot be negative.");
	}
	else
	{
		ANLogDebug(@"Ad view autorefresh interval set to %f seconds", autorefreshInterval);
		__autorefreshInterval = autorefreshInterval;
		
		if (autorefreshInterval > 0.0f && ![self.adFetcher isLoading])
		{
			ANLogDebug(@"New autorefresh interval set. Making ad request.");
			[self.adFetcher requestAd];
		}
		else if (autorefreshInterval == 0.0f)
		{
			BOOL adFetcherWasLoading = [self.adFetcher isLoading];
			
			ANLogDebug(@"Stopping autorefresh");
			[self.adFetcher stopAd];
			
			if (!adFetcherWasLoading)
			{
				[self.adFetcher requestAd];
			}
		}
	}
}

- (void)setFrame:(CGRect)frame animated:(BOOL)animated
{
    if (animated)
    {
		if ([self.delegate respondsToSelector:@selector(bannerAdView:willResizeToFrame:)])
		{
			[self.delegate bannerAdView:self willResizeToFrame:frame];
		}
        [UIView animateWithDuration:kAppNexusAnimationDuration animations:^{
            [self setFrame:frame];
        } completion:^(BOOL finished) {
			if ([self.delegate respondsToSelector:@selector(bannerAdViewDidResize:)])
			{
				[self.delegate bannerAdViewDidResize:self];
			}
		}];
    }
    else
    {
		if ([self.delegate respondsToSelector:@selector(bannerAdView:willResizeToFrame:)])
		{
			[self.delegate bannerAdView:self willResizeToFrame:frame];
		}
        [self setFrame:frame];
		if ([self.delegate respondsToSelector:@selector(bannerAdViewDidResize:)])
		{
			[self.delegate bannerAdViewDidResize:self];
		}
    }
}

#pragma mark ANAdFetcherDelegate

- (void)adFetcher:(ANAdFetcher *)fetcher adShouldResizeToSize:(CGSize)size
{
    CGRect frame = self.frame;
	frame.origin.x = frame.origin.x - (size.width - frame.size.width) / 2;
    frame.size.width = size.width;
    frame.size.height = size.height;
    
    [self setFrame:frame animated:YES];
}

- (void)adFetcher:(ANAdFetcher *)fetcher didFinishRequestWithResponse:(ANAdResponse *)response
{
    if ([response isSuccessful])
    {
        UIView *contentView = response.adObject;
		
		if ([contentView isKindOfClass:[UIView class]])
		{
			self.contentView = contentView;
			
			if ([self.delegate respondsToSelector:@selector(adDidReceiveAd:)])
			{
				[self.delegate adDidReceiveAd:self];
			}
		}
		else
		{
			NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Requested a banner ad but received a non-view object as response.", @"Error: We did not get a viewable object as a response for a banner ad request.")
																  forKey:NSLocalizedDescriptionKey];
			NSError *badResponseError = [NSError errorWithDomain:AN_ERROR_DOMAIN code:ANAdResponseNonViewResponse userInfo:errorInfo];
			[self.delegate ad:self requestFailedWithError:badResponseError];
		}
    }
    else
    {
		if ([self.delegate respondsToSelector:@selector(ad:requestFailedWithError:)])
		{
			[self.delegate ad:self requestFailedWithError:response.error];
		}
    }
}

- (NSArray *)extraParametersForAdFetcher:(ANAdFetcher *)fetcher
{
    return [NSArray arrayWithObjects:
            [self placementSizeParameter],
            [self maximumSizeParameter],
            nil];
}

- (NSTimeInterval)autorefreshIntervalForAdFetcher:(ANAdFetcher *)fetcher
{
    return self.autorefreshInterval;
}

@end
