/*   Copyright 2015 APPNEXUS INC
 
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

// ================================================================================================
//  TBXML.h
//  Fast processing of XML files
//
// ================================================================================================
//  Created by Tom Bradley on 21/10/2009.
//  Version 1.5
//  
//  Copyright 2012 71Squared All rights reserved.b
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
// ================================================================================================

#import <Foundation/Foundation.h>

#define ANXML_ARC_ENABLED 1

@class ANXML;

// ================================================================================================
//  Error Codes
// ================================================================================================
enum ANXMLErrorCodes {
    D_ANXML_SUCCESS = 0,

    D_ANXML_DATA_NIL,
    D_ANXML_DECODE_FAILURE,
    D_ANXML_MEMORY_ALLOC_FAILURE,
    D_ANXML_FILE_NOT_FOUND_IN_BUNDLE,
    
    D_ANXML_ELEMENT_IS_NIL,
    D_ANXML_ELEMENT_NAME_IS_NIL,
    D_ANXML_ELEMENT_NOT_FOUND,
    D_ANXML_ELEMENT_TEXT_IS_NIL,
    D_ANXML_ATTRIBUTE_IS_NIL,
    D_ANXML_ATTRIBUTE_NAME_IS_NIL,
    D_ANXML_ATTRIBUTE_NOT_FOUND,
    D_ANXML_PARAM_NAME_IS_NIL
};


// ================================================================================================
//  Defines
// ================================================================================================
#define D_ANXML_DOMAIN @"com.71squared.tbxml"

#define ANXML_MAX_ELEMENTS 100
#define ANXML_MAX_ATTRIBUTES 100

#define ANXML_ATTRIBUTE_NAME_START 0
#define ANXML_ATTRIBUTE_NAME_END 1
#define ANXML_ATTRIBUTE_VALUE_START 2
#define ANXML_ATTRIBUTE_VALUE_END 3
#define ANXML_ATTRIBUTE_CDATA_END 4

// ================================================================================================
//  Structures
// ================================================================================================

/** The ANXMLAttribute structure holds information about a single XML attribute. The structure holds the attribute name, value and next sibling attribute. This structure allows us to create a linked list of attributes belonging to a specific element.
 */
typedef struct _ANXMLAttribute {
	char * name;
	char * value;
	struct _ANXMLAttribute * next;
} ANXMLAttribute;



/** The ANXMLElement structure holds information about a single XML element. The structure holds the element name & text along with pointers to the first attribute, parent element, first child element and first sibling element. Using this structure, we can create a linked list of ANXMLElements to map out an entire XML file.
 */
typedef struct _ANXMLElement {
	char * name;
	char * text;
	
	ANXMLAttribute * firstAttribute;
	
	struct _ANXMLElement * parentElement;
	
	struct _ANXMLElement * firstChild;
	struct _ANXMLElement * currentChild;
	
	struct _ANXMLElement * nextSibling;
	struct _ANXMLElement * previousSibling;
	
} ANXMLElement;

/** The ANXMLElementBuffer is a structure that holds a buffer of ANXMLElements. When the buffer of elements is used, an additional buffer is created and linked to the previous one. This allows for efficient memory allocation/deallocation elements.
 */
typedef struct _ANXMLElementBuffer {
	ANXMLElement * elements;
	struct _ANXMLElementBuffer * next;
	struct _ANXMLElementBuffer * previous;
} ANXMLElementBuffer;



/** The ANXMLAttributeBuffer is a structure that holds a buffer of ANXMLAttributes. When the buffer of attributes is used, an additional buffer is created and linked to the previous one. This allows for efficient memeory allocation/deallocation of attributes.
 */
typedef struct _ANXMLAttributeBuffer {
	ANXMLAttribute * attributes;
	struct _ANXMLAttributeBuffer * next;
	struct _ANXMLAttributeBuffer * previous;
} ANXMLAttributeBuffer;


// ================================================================================================
//  Block Callbacks
// ================================================================================================
typedef void (^ANXMLSuccessBlock)(ANXML *tbxml);
typedef void (^ANXMLFailureBlock)(ANXML *tbxml, NSError *error);
typedef void (^ANXMLIterateBlock)(ANXMLElement *element);
typedef void (^ANXMLIterateAttributeBlock)(ANXMLAttribute *attribute, NSString *attributeName, NSString *attributeValue);


// ================================================================================================
//  ANXML Public Interface
// ================================================================================================

@interface ANXML : NSObject {
	
@private
	ANXMLElement * rootXMLElement;
	
	ANXMLElementBuffer * currentElementBuffer;
	ANXMLAttributeBuffer * currentAttributeBuffer;
	
	long currentElement;
	long currentAttribute;
	
	char * bytes;
	long bytesLength;
}


@property (nonatomic, readonly) ANXMLElement * rootXMLElement;

+ (id)newANXMLWithXMLString:(NSString*)aXMLString error:(NSError **)error;
+ (id)newANXMLWithXMLData:(NSData*)aData error:(NSError **)error;
+ (id)newANXMLWithXMLFile:(NSString*)aXMLFile error:(NSError **)error;
+ (id)newANXMLWithXMLFile:(NSString*)aXMLFile fileExtension:(NSString*)aFileExtension error:(NSError **)error;

+ (id)newANXMLWithXMLString:(NSString*)aXMLString __attribute__((deprecated));
+ (id)newANXMLWithXMLData:(NSData*)aData __attribute__((deprecated));
+ (id)newANXMLWithXMLFile:(NSString*)aXMLFile __attribute__((deprecated));
+ (id)newANXMLWithXMLFile:(NSString*)aXMLFile fileExtension:(NSString*)aFileExtension __attribute__((deprecated));


- (id)initWithXMLString:(NSString*)aXMLString error:(NSError **)error;
- (id)initWithXMLData:(NSData*)aData error:(NSError **)error;
- (id)initWithXMLFile:(NSString*)aXMLFile error:(NSError **)error;
- (id)initWithXMLFile:(NSString*)aXMLFile fileExtension:(NSString*)aFileExtension error:(NSError **)error;

- (id)initWithXMLString:(NSString*)aXMLString __attribute__((deprecated));
- (id)initWithXMLData:(NSData*)aData __attribute__((deprecated));
- (id)initWithXMLFile:(NSString*)aXMLFile __attribute__((deprecated));
- (id)initWithXMLFile:(NSString*)aXMLFile fileExtension:(NSString*)aFileExtension __attribute__((deprecated));


- (int) decodeData:(NSData*)data;
- (int) decodeData:(NSData*)data withError:(NSError **)error;

@end

// ================================================================================================
//  ANXML Static Functions Interface
// ================================================================================================

@interface ANXML (StaticFunctions)

+ (NSString*) elementName:(ANXMLElement*)aXMLElement;
+ (NSString*) elementName:(ANXMLElement*)aXMLElement error:(NSError **)error;
+ (NSString*) textForElement:(ANXMLElement*)aXMLElement;
+ (NSString*) textForElement:(ANXMLElement*)aXMLElement error:(NSError **)error;
+ (NSString*) valueOfAttributeNamed:(NSString *)aName forElement:(ANXMLElement*)aXMLElement;
+ (NSString*) valueOfAttributeNamed:(NSString *)aName forElement:(ANXMLElement*)aXMLElement error:(NSError **)error;

+ (NSString*) attributeName:(ANXMLAttribute*)aXMLAttribute;
+ (NSString*) attributeName:(ANXMLAttribute*)aXMLAttribute error:(NSError **)error;
+ (NSString*) attributeValue:(ANXMLAttribute*)aXMLAttribute;
+ (NSString*) attributeValue:(ANXMLAttribute*)aXMLAttribute error:(NSError **)error;

+ (ANXMLElement*) nextSiblingNamed:(NSString*)aName searchFromElement:(ANXMLElement*)aXMLElement;
+ (ANXMLElement*) childElementNamed:(NSString*)aName parentElement:(ANXMLElement*)aParentXMLElement;

+ (ANXMLElement*) nextSiblingNamed:(NSString*)aName searchFromElement:(ANXMLElement*)aXMLElement error:(NSError **)error;
+ (ANXMLElement*) childElementNamed:(NSString*)aName parentElement:(ANXMLElement*)aParentXMLElement error:(NSError **)error;

/** Iterate through all elements found using query.
 
 Inspiration taken from John Blanco's RaptureXML https://github.com/ZaBlanc/RaptureXML
 */
+ (void)iterateElementsForQuery:(NSString *)query fromElement:(ANXMLElement *)anElement withBlock:(ANXMLIterateBlock)iterateBlock;
+ (void)iterateAttributesOfElement:(ANXMLElement *)anElement withBlock:(ANXMLIterateAttributeBlock)iterateBlock;


@end
