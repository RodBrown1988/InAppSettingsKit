//
//  IASKSpecifier.m
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

#import "IASKSpecifier.h"
#import "IASKSettingsReader.h"
#import "IASKAppSettingsWebViewController.h"

@interface IASKSpecifier ()

@property (nonatomic, retain) NSDictionary  *multipleValuesDict;
@property (nonatomic, copy) NSString *radioGroupValue;

@end

@implementation IASKSpecifier

- (id)initWithSpecifier:(NSDictionary*)specifier {
    if ((self = [super init])) {
        [self setSpecifierDict:specifier];

        if ([self isMultiValueSpecifierType]) {
            [self updateMultiValuesDict];
        }
    }
    return self;
}

- (BOOL)isMultiValueSpecifierType {
    static NSArray *types = nil;
    if (!types) {
        types = @[kIASKPSMultiValueSpecifier, kIASKPSTitleValueSpecifier, kIASKPSRadioGroupSpecifier];
    }
	NSString *type = self.type;
	if (type != nil) {
    	return [types containsObject:type];
	} else {
		return NO;
	}
}

- (id)initWithSpecifier:(NSDictionary *)specifier
        radioGroupValue:(NSString *)radioGroupValue {

    self = [self initWithSpecifier:specifier];
    if (self) {
        self.radioGroupValue = radioGroupValue;
    }
    return self;
}

- (void)updateMultiValuesDict {
    NSArray *values = [_specifierDict objectForKey:kIASKValues];
    NSArray *titles = [_specifierDict objectForKey:kIASKTitles];
	[self setMultipleValuesDictValues:values titles:titles];
}

- (void)setMultipleValuesDictValues:(NSArray*)values titles:(NSArray*)titles {
    NSArray *shortTitles = [_specifierDict objectForKey:kIASKShortTitles];
    NSArray *iconNames = [_specifierDict objectForKey:kIASKIconNames];
    NSMutableDictionary *multipleValuesDict = [NSMutableDictionary new];
   
    if (values) {
        [multipleValuesDict setObject:values forKey:kIASKValues];
    }
	
    if (titles) {
        [multipleValuesDict setObject:titles forKey:kIASKTitles];
    }

    if (shortTitles.count) {
        [multipleValuesDict setObject:shortTitles forKey:kIASKShortTitles];
    }

    if (iconNames.count) {
        [multipleValuesDict setObject:iconNames forKey:kIASKIconNames];
    }

    [self setMultipleValuesDict:multipleValuesDict];
}

- (void)sortIfNeeded {
    if (self.displaySortedByTitle) {
        NSArray *values = self.multipleValues ?: [_specifierDict objectForKey:kIASKValues];
        NSArray *titles = self.multipleTitles ?: [_specifierDict objectForKey:kIASKTitles];
        NSArray *shortTitles = self.multipleShortTitles ?: [_specifierDict objectForKey:kIASKShortTitles];
        NSArray *iconNames = self.multipleIconNames ?: [_specifierDict objectForKey:kIASKIconNames];

        NSAssert(values.count == titles.count, @"Malformed multi-value specifier found in settings bundle. Number of values and titles differ.");
        NSAssert(shortTitles == nil || shortTitles.count == values.count, @"Malformed multi-value specifier found in settings bundle. Number of short titles and values differ.");
        NSAssert(iconNames == nil || iconNames.count == values.count, @"Malformed multi-value specifier found in settings bundle. Number of icon names and values differ.");

        NSMutableDictionary *multipleValuesDict = [NSMutableDictionary new];

        NSMutableArray *temporaryMappingsForSort = [NSMutableArray arrayWithCapacity:titles.count];

        static NSString *const titleKey = @"title";
        static NSString *const shortTitleKey = @"shortTitle";
        static NSString *const localizedTitleKey = @"localizedTitle";
        static NSString *const iconNamesKey = @"iconNamesKey";
        static NSString *const valueKey = @"value";

        IASKSettingsReader *strongSettingsReader = self.settingsReader;
        [titles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *localizedTitle = [strongSettingsReader titleForId:obj];
            [temporaryMappingsForSort addObject:@{titleKey : obj,
                                                  valueKey : values[idx],
                                                  localizedTitleKey : localizedTitle,
                                                  shortTitleKey : (shortTitles[idx] ?: [NSNull null]),
                                                  iconNamesKey : (iconNames[idx] ?: [NSNull null]),
                                                  }];
        }];
        
        NSArray *sortedTemporaryMappings = [temporaryMappingsForSort sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString *localizedTitle1 = obj1[localizedTitleKey];
            NSString *localizedTitle2 = obj2[localizedTitleKey];

            if ([localizedTitle1 isKindOfClass:[NSString class]] && [localizedTitle2 isKindOfClass:[NSString class]]) {
                return [localizedTitle1 localizedCompare:localizedTitle2];
            } else {
                return NSOrderedSame;
            }
        }];
        
        NSMutableArray *sortedTitles = [NSMutableArray arrayWithCapacity:sortedTemporaryMappings.count];
        NSMutableArray *sortedShortTitles = [NSMutableArray arrayWithCapacity:sortedTemporaryMappings.count];
        NSMutableArray *sortedValues = [NSMutableArray arrayWithCapacity:sortedTemporaryMappings.count];
        NSMutableArray *sortedIconNames = [NSMutableArray arrayWithCapacity:sortedTemporaryMappings.count];

        [sortedTemporaryMappings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *mapping = obj;
            sortedTitles[idx] = (NSString *)mapping[titleKey];
            sortedValues[idx] = (id)mapping[valueKey];
            if (mapping[shortTitleKey] != [NSNull null]) {
                sortedShortTitles[idx] = (id)mapping[shortTitleKey];
            }
            if (mapping[iconNamesKey] != [NSNull null]) {
                sortedIconNames[idx] = (id)mapping[iconNamesKey];
            }
        }];
        titles = [sortedTitles copy];
        values = [sortedValues copy];
        shortTitles = [sortedShortTitles copy];
        iconNames = [iconNames copy];
        
        if (values) {
            [multipleValuesDict setObject:values forKey:kIASKValues];
        }
        
        if (titles) {
            [multipleValuesDict setObject:titles forKey:kIASKTitles];
        }
        
        if (shortTitles.count) {
            [multipleValuesDict setObject:shortTitles forKey:kIASKShortTitles];
        }

        if (iconNames.count) {
            [multipleValuesDict setObject:iconNames forKey:kIASKIconNames];
        }

        [self setMultipleValuesDict:multipleValuesDict];
    }
}

- (BOOL)displaySortedByTitle {
    return [[_specifierDict objectForKey:kIASKDisplaySortedByTitle] boolValue];
}

- (NSString*)localizedObjectForKey:(NSString*)key {
	IASKSettingsReader *settingsReader = self.settingsReader;
	return [settingsReader titleForId:[_specifierDict objectForKey:key]];
}

- (NSString*)title {
    return [self localizedObjectForKey:kIASKTitle];
}

- (NSString*)subtitle {
	return [self localizedObjectForKey:kIASKSubtitle];
}

- (NSString *)placeholder {
    return [self localizedObjectForKey:kIASKPlaceholder];
}

- (NSString*)footerText {
    return [self localizedObjectForKey:kIASKFooterText];
}

- (Class)viewControllerClass {
    [IASKAppSettingsWebViewController class]; // make sure this is linked into the binary/library
	NSString *classString = [_specifierDict objectForKey:kIASKViewControllerClass];
	return classString ? ([self classFromString:classString] ?: [NSNull class]) : nil;
}

- (Class)classFromString:(NSString *)className {
    Class class = NSClassFromString(className);
    if (!class) {
        // if the class doesn't exist as a pure Obj-C class then try to retrieve it as a Swift class.
        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
        NSString *classStringName = [NSString stringWithFormat:@"_TtC%lu%@%lu%@", (unsigned long)appName.length, appName, (unsigned long)className.length, className];
        class = NSClassFromString(classStringName);
    }
    return class;
}

- (SEL)viewControllerSelector {
    NSString *selector = [_specifierDict objectForKey:kIASKViewControllerSelector];
    return selector ? NSSelectorFromString(selector) : nil;
}

- (NSString*)viewControllerStoryBoardFile {
	return [_specifierDict objectForKey:kIASKViewControllerStoryBoardFile];
}

- (NSString*)viewControllerStoryBoardID {
	return [_specifierDict objectForKey:kIASKViewControllerStoryBoardId];
}

- (NSString*)segueIdentifier {
    return [_specifierDict objectForKey:kIASKSegueIdentifier];
}

- (Class)buttonClass {
    NSString *buttonClassString = [_specifierDict objectForKey:kIASKButtonClass];
    return buttonClassString ? NSClassFromString(buttonClassString) : nil;
}

- (SEL)buttonAction {
    NSString *buttonAction = [_specifierDict objectForKey:kIASKButtonAction];
    return buttonAction ? NSSelectorFromString(buttonAction) : nil;
}

- (NSString*)key {
    return [_specifierDict objectForKey:kIASKKey];
}

- (NSString*)type {
    return [_specifierDict objectForKey:kIASKType];
}

- (NSString*)titleForCurrentValue:(id)currentValue {
	NSArray *values = [self multipleValues];
	NSArray *titles = [self multipleShortTitles] ?: self.multipleTitles;
	if (!titles) {
        titles = [self multipleTitles];
	}
	if (values.count != titles.count) {
		return nil;
	}
    NSInteger keyIndex = [values indexOfObject:currentValue];
	if (keyIndex == NSNotFound) {
		return nil;
	}
	@try {
		IASKSettingsReader *strongSettingsReader = self.settingsReader;
		return [strongSettingsReader titleForId:[titles objectAtIndex:keyIndex]];
	}
	@catch (NSException * e) {}
	return nil;
}

- (NSInteger)multipleValuesCount {
    return [[_multipleValuesDict objectForKey:kIASKValues] count];
}

- (NSArray*)multipleValues {
    return [_multipleValuesDict objectForKey:kIASKValues];
}

- (NSArray*)multipleTitles {
    return [_multipleValuesDict objectForKey:kIASKTitles];
}

- (NSArray *)multipleIconNames {
    return [_multipleValuesDict objectForKey:kIASKIconNames];
}

- (NSArray*)multipleShortTitles {
    return [_multipleValuesDict objectForKey:kIASKShortTitles];
}

- (NSString*)file {
    return [_specifierDict objectForKey:kIASKFile];
}

- (id)defaultValue {
    return [_specifierDict objectForKey:kIASKDefaultValue];
}

- (id)defaultStringValue {
    return [[_specifierDict objectForKey:kIASKDefaultValue] description];
}

- (BOOL)defaultBoolValue {
	id defaultValue = [self defaultValue];
	if ([defaultValue isEqual:[self trueValue]]) {
		return YES;
	}
	if ([defaultValue isEqual:[self falseValue]]) {
		return NO;
	}
	return [defaultValue boolValue];
}

- (id)trueValue {
    return [_specifierDict objectForKey:kIASKTrueValue];
}

- (id)falseValue {
    return [_specifierDict objectForKey:kIASKFalseValue];
}

- (float)minimumValue {
    return [[_specifierDict objectForKey:kIASKMinimumValue] floatValue];
}

- (float)maximumValue {
    return [[_specifierDict objectForKey:kIASKMaximumValue] floatValue];
}

- (NSString*)minimumValueImage {
    return [_specifierDict objectForKey:kIASKMinimumValueImage];
}

- (NSString*)maximumValueImage {
    return [_specifierDict objectForKey:kIASKMaximumValueImage];
}

- (BOOL)isSecure {
    return [[_specifierDict objectForKey:kIASKIsSecure] boolValue];
}

- (UIKeyboardType)keyboardType {
    if ([[_specifierDict objectForKey:KIASKKeyboardType] isEqualToString:kIASKKeyboardAlphabet]) {
        return UIKeyboardTypeDefault;
    }
    else if ([[_specifierDict objectForKey:KIASKKeyboardType] isEqualToString:kIASKKeyboardNumbersAndPunctuation]) {
        return UIKeyboardTypeNumbersAndPunctuation;
    }
    else if ([[_specifierDict objectForKey:KIASKKeyboardType] isEqualToString:kIASKKeyboardNumberPad]) {
        return UIKeyboardTypeNumberPad;
    }
    else if ([[_specifierDict objectForKey:KIASKKeyboardType] isEqualToString:kIASKKeyboardPhonePad]) {
        return UIKeyboardTypePhonePad;
    }
    else if ([[_specifierDict objectForKey:KIASKKeyboardType] isEqualToString:kIASKKeyboardNamePhonePad]) {
        return UIKeyboardTypeNamePhonePad;
    }
    else if ([[_specifierDict objectForKey:KIASKKeyboardType] isEqualToString:kIASKKeyboardASCIICapable]) {
        return UIKeyboardTypeASCIICapable;
    }
    else if ([[_specifierDict objectForKey:KIASKKeyboardType] isEqualToString:kIASKKeyboardDecimalPad]) {
		return UIKeyboardTypeDecimalPad;
    }
    else if ([[_specifierDict objectForKey:KIASKKeyboardType] isEqualToString:KIASKKeyboardURL]) {
        return UIKeyboardTypeURL;
    }
    else if ([[_specifierDict objectForKey:KIASKKeyboardType] isEqualToString:kIASKKeyboardEmailAddress]) {
        return UIKeyboardTypeEmailAddress;
    }
    return UIKeyboardTypeDefault;
}

- (UITextAutocapitalizationType)autocapitalizationType {
    if ([[_specifierDict objectForKey:kIASKAutocapitalizationType] isEqualToString:kIASKAutoCapNone]) {
        return UITextAutocapitalizationTypeNone;
    }
    else if ([[_specifierDict objectForKey:kIASKAutocapitalizationType] isEqualToString:kIASKAutoCapSentences]) {
        return UITextAutocapitalizationTypeSentences;
    }
    else if ([[_specifierDict objectForKey:kIASKAutocapitalizationType] isEqualToString:kIASKAutoCapWords]) {
        return UITextAutocapitalizationTypeWords;
    }
    else if ([[_specifierDict objectForKey:kIASKAutocapitalizationType] isEqualToString:kIASKAutoCapAllCharacters]) {
        return UITextAutocapitalizationTypeAllCharacters;
    }
    return UITextAutocapitalizationTypeNone;
}

- (UITextAutocorrectionType)autoCorrectionType {
    if ([[_specifierDict objectForKey:kIASKAutoCorrectionType] isEqualToString:kIASKAutoCorrDefault]) {
        return UITextAutocorrectionTypeDefault;
    }
    else if ([[_specifierDict objectForKey:kIASKAutoCorrectionType] isEqualToString:kIASKAutoCorrNo]) {
        return UITextAutocorrectionTypeNo;
    }
    else if ([[_specifierDict objectForKey:kIASKAutoCorrectionType] isEqualToString:kIASKAutoCorrYes]) {
        return UITextAutocorrectionTypeYes;
    }
    return UITextAutocorrectionTypeDefault;
}

- (UIImage *)cellImage
{
    NSString *imageName = [_specifierDict objectForKey:kIASKCellImage];
    if( imageName.length == 0 )
        return nil;
    
    return [UIImage imageNamed:imageName];
}

- (UIImage *)highlightedCellImage
{
    NSString *imageName = [[_specifierDict objectForKey:kIASKCellImage ] stringByAppendingString:@"Highlighted"];
    if( imageName.length == 0 )
        return nil;

    return [UIImage imageNamed:imageName];
}

- (BOOL)adjustsFontSizeToFitWidth {
	NSNumber *boxedResult = [_specifierDict objectForKey:kIASKAdjustsFontSizeToFitWidth];
	return (boxedResult == nil) || [boxedResult boolValue];
}

- (NSTextAlignment)textAlignment
{
    if (self.subtitle.length || [[_specifierDict objectForKey:kIASKTextLabelAlignment] isEqualToString:kIASKTextLabelAlignmentLeft]) {
        return NSTextAlignmentLeft;
    } else if ([[_specifierDict objectForKey:kIASKTextLabelAlignment] isEqualToString:kIASKTextLabelAlignmentCenter]) {
        return NSTextAlignmentCenter;
    } else if ([[_specifierDict objectForKey:kIASKTextLabelAlignment] isEqualToString:kIASKTextLabelAlignmentRight]) {
        return NSTextAlignmentRight;
    }
    if ([self.type isEqualToString:kIASKButtonSpecifier] && !self.cellImage) {
		return NSTextAlignmentCenter;
	} else if ([self.type isEqualToString:kIASKPSMultiValueSpecifier] || [self.type isEqualToString:kIASKPSTitleValueSpecifier] || [self.type isEqualToString:kIASKTextViewSpecifier]) {
		return NSTextAlignmentRight;
	}
	return NSTextAlignmentLeft;
}

- (NSArray *)userInterfaceIdioms {
    NSArray *idiomStrings = _specifierDict[kIASKSupportedUserInterfaceIdioms];
    if (idiomStrings.count == 0) {
        return @[@(UIUserInterfaceIdiomPhone), @(UIUserInterfaceIdiomPad)];
    }
    NSMutableArray *idioms = [NSMutableArray new];
    for (NSString *idiomString in idiomStrings) {
        if ([idiomString isEqualToString:@"Phone"]) {
            [idioms addObject:@(UIUserInterfaceIdiomPhone)];
        } else if ([idiomString isEqualToString:@"Pad"]) {
            [idioms addObject:@(UIUserInterfaceIdiomPad)];
        }
    }
    return idioms;
}

- (id)valueForKey:(NSString *)key {
	return [_specifierDict objectForKey:key];
}
@end
