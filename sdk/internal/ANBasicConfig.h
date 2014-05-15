/*   Copyright 2014 APPNEXUS INC
 
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

#ifndef ANSDK_ANBasicConfig_h
#define ANSDK_ANBasicConfig_h

#ifdef EXTERNAL_CONFIG
#include "ANExtendedConfig.h"
#else
#define ANADPROTOCOL ANAdProtocol
#define ANADVIEW ANAdView
#define ANBANNERADVIEW ANBannerAdView
#define ANINTERSTITIALAD ANInterstitialAd
#define ANLOCATION ANLocation
#define ANGENDER ANGender
#define ANADDELEGATE ANAdDelegate
#define ANAPPEVENTDELEGATE ANAppEventDelegate
#define ANBANNERADVIEWDELEGATE ANBannerAdViewDelegate
#define ANINTERSTITIALADDELEGATE ANInterstitialAdDelegate
#define ANTARGETINGPARAMETERS ANTargetingParameters
#define ANMOPUBMEDIATIONBANNER ANMoPubMediationBanner
#define ANMOPUBMEDIATIONINTERSTITIAL ANMoPubMediationInterstitial
#define ANGADCUSTOMBANNERAD ANGADCustomBannerAd
#define ANGADCUSTOMINTERSTITIALAD ANGADCustomInterstitialAd

#define ANADPROTOCOLHEADER "ANAdProtocol.h"
#define ANADVIEWHEADER "ANAdView.h"
#define ANBANNERADVIEWHEADER "ANBannerAdView.h"
#define ANINTERSTITIALADHEADER "ANInterstitialAd.h"
#define ANLOCATIONHEADER "ANLocation.h"
#define ANTARGETINGPARAMETERSHEADER "ANTargetingParameters.h"
#define ANCUSTOMADAPTERHEADER "ANCustomAdapter.h"
#define ANMOPUBMEDIATIONBANNERHEADER "ANMoPubMediationBanner.h"
#define ANMOPUBMEDIATIONINTERSTITIALHEADER "ANMoPubMediationInterstitial.h"
#define ANGADCUSTOMBANNERADHEADER "ANGADCustomBannerAd.h"
#define ANGADCUSTOMINTERSTITIALADHEADER "ANGADCustomInterstitialAd.h"

#define AN_RESOURCE_BUNDLE @"ANSDKResources"
#define AN_LOG_NAME @"APPNEXUS"

#define ANCUSTOMADAPTER ANCustomAdapter
#define ANCUSTOMADAPTERBANNER ANCustomAdapterBanner
#define ANCUSTOMADAPTERINTERSTITIAL ANCustomAdapterInterstitial
#define ANCUSTOMADAPTERDELEGATE ANCustomAdapterDelegate
#define ANCUSTOMADAPTERBANNERDELEGATE ANCustomAdapterBannerDelegate
#define ANCUSTOMADAPTERINTERSTITIALDELEGATE ANCustomAdapterInterstitialDelegate
#define ANADRESPONSECODE ANAdResponseCode

#define ANADADAPTERBANNERADMOB ANAdAdapterBannerAdMob
#define ANADADAPTERINTERSTITIALADMOB ANAdAdapterInterstitialAdMob
#define ANADADAPTERBANNERADMOBHEADER "ANAdAdapterBannerAdMob.h"
#define ANADADAPTERINTERSTITIALADMOBHEADER "ANAdAdapterInterstitialAdMob.h"

#define ANADADAPTERBANNERIAD ANAdAdapterBanneriAd
#define ANADADAPTERBANNERIADHEADER "ANAdAdapterBanneriAd.h"
#define ANADADAPTERINTERSTITIALIAD ANAdAdapterInterstitialiAd
#define ANADADAPTERINTERSTITIALIADHEADER "ANAdAdapterInterstitialiAd.h"

#define ANADADAPTERBANNERDFP ANAdAdapterBannerDFP
#define ANADADAPTERBANNERDFPHEADER "ANAdAdapterBannerDFP.h"
#define ANADADAPTERINTERSTITIALDFP ANAdAdapterInterstitialDFP
#define ANADADAPTERINTERSTITIALDFPHEADER "ANAdAdapterInterstitialDFP.h"

#define ANADADAPTERBANNERMILLENNIALMEDIA ANAdAdapterBannerMillennialMedia
#define ANADADAPTERBANNERMILLENNIALMEDIAHEADER "ANAdAdapterBannerMillennialMedia.h"
#define ANADADAPTERINTERSTITIALMILLENNIALMEDIA ANAdAdapterInterstitialMillennialMedia
#define ANADADAPTERINTERSTITIALMILLENNIALMEDIAHEADER "ANAdAdapterInterstitialMillennialMedia.h"
#define ANADADAPTERMILLENNIALMEDIABASE ANAdAdapterMillennialMediaBase
#define ANADADAPTERMILLENNIALMEDIABASEHEADER "ANAdAdapterMillennialMediaBase.h"

#endif

#endif