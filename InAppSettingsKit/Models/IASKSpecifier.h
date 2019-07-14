//
//  IASKSpecifier.h
//  http://www.inappsettingskit.com
//
//  Copyright (c) 2009:
//  Luc Vandal, Edovia Inc., http://www.edovia.com
//  Ortwin Gentz, FutureTap GmbH, http://www.futuretap.com
//  All rights reserved.
//
//  It is appreciated but not required that you give credit to Luc Vandal and Ortwin Gentz,
//  as the original authors of this code. You can give credit in a blog post, a tweet or on
//  a info page of your app. Also, the original authors appreciate letting them know if you use this code.
//
//  This code is licensed under the BSD license that is available at: http://www.opensource.org/licenses/bsd-license.php
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class IASKSettingsReader;

@interface IASKSpecifier : NSObject

@property (nonatomic, strong) NSDictionary  *specifierDict;
@property (nonatomic, weak) IASKSettingsReader *settingsReader;

- (id)initWithSpecifier:(NSDictionary*)specifier;
/// A specifier for one entry in a radio group preceeded by a radio group specifier.
- (id)initWithSpecifier:(NSDictionary *)specifier
        radioGroupValue:(NSString *)radioGroupValue;

- (void)setMultipleValuesDictValues:(nullable NSArray *)values
							 titles:(nullable NSArray<NSString *> *)titles;

- (void)sortIfNeeded;

- (nullable NSString*)localizedObjectForKey:(NSString *)key;

@property (nonatomic, readonly, nullable) NSString *file;

@property (nonatomic, readonly, nullable) NSString *title;
@property (nonatomic, readonly, nullable) NSString *subtitle;
@property (nonatomic, readonly, nullable) NSString *placeholder;
@property (nonatomic, readonly, nullable) NSString *key;
@property (nonatomic, readonly, nullable) NSString *type;

- (nullable NSString *)titleForCurrentValue:(id)currentValue;

@property (nonatomic, readonly, nullable) id defaultValue;
@property (nonatomic, readonly, nullable) NSString *defaultStringValue;
@property (nonatomic, readonly) BOOL defaultBoolValue;

@property (nonatomic, readonly, nullable) NSString *radioGroupValue;

@property (nonatomic, readonly) NSInteger multipleValuesCount;
@property (nonatomic, readonly, nullable) NSArray *multipleValues;
@property (nonatomic, readonly, nullable) NSArray<NSString *> *multipleTitles;
@property (nonatomic, readonly, nullable) NSArray *multipleIconNames;

@property (nonatomic, readonly, nullable) id trueValue;
@property (nonatomic, readonly, nullable) id falseValue;

@property (nonatomic, readonly) float minimumValue;
@property (nonatomic, readonly) float maximumValue;
@property (nonatomic, readonly, nullable) NSString *minimumValueImage;
@property (nonatomic, readonly, nullable) NSString *maximumValueImage;

@property (nonatomic, readonly) BOOL isSecure;
@property (nonatomic, readonly) UIKeyboardType keyboardType;
@property (nonatomic, readonly) UITextAutocapitalizationType autocapitalizationType;
@property (nonatomic, readonly) UITextAutocorrectionType autoCorrectionType;

@property (nonatomic, readonly, nullable) NSString *footerText;

@property (nonatomic, readonly, nullable) Class viewControllerClass;
@property (nonatomic, readonly, nullable) SEL viewControllerSelector;
@property (nonatomic, readonly, nullable) NSString *viewControllerStoryBoardFile;
@property (nonatomic, readonly, nullable) NSString *viewControllerStoryBoardID;
@property (nonatomic, readonly, nullable) NSString *segueIdentifier;

@property (nonatomic, readonly, nullable) Class buttonClass;
@property (nonatomic, readonly, nullable) SEL buttonAction;

@property (nonatomic, readonly, nullable) UIImage *cellImage;
@property (nonatomic, readonly, nullable) UIImage *highlightedCellImage;

@property (nonatomic, readonly) BOOL adjustsFontSizeToFitWidth;
@property (nonatomic, readonly) NSTextAlignment textAlignment;

@property (nonatomic, readonly, nullable) NSArray *userInterfaceIdioms;

- (BOOL)displaySortedByTitle;

@end

NS_ASSUME_NONNULL_END
