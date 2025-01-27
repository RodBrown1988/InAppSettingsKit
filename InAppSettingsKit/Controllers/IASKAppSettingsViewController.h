//
//  IASKAppSettingsViewController.h
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

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import <InAppSettingsKit/IASKSettingsStore.h>
#import <InAppSettingsKit/IASKViewController.h>
#import <InAppSettingsKit/IASKSpecifier.h>

NS_ASSUME_NONNULL_BEGIN

@class IASKSettingsReader;
@class IASKAppSettingsViewController;

@protocol IASKSettingsDelegate <NSObject>

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender;

@optional
#pragma mark - UITableView header customization
- (NSString *) settingsViewController:(id<IASKViewController>)settingsViewController
                            tableView:(UITableView *)tableView
             titleForHeaderForSection:(NSInteger)section;
- (CGFloat) settingsViewController:(id<IASKViewController>)settingsViewController
                         tableView:(UITableView *)tableView
         heightForHeaderForSection:(NSInteger)section;
- (UIView *) settingsViewController:(id<IASKViewController>)settingsViewController
                          tableView:(UITableView *)tableView
            viewForHeaderForSection:(NSInteger)section;

#pragma mark - UITableView footer customization
- (NSString *) settingsViewController:(id<IASKViewController>)settingsViewController
                            tableView:(UITableView *)tableView
             titleForFooterForSection:(NSInteger)section;
- (CGFloat) settingsViewController:(id<IASKViewController>)settingsViewController
                         tableView:(UITableView *)tableView
         heightForFooterForSection:(NSInteger)section;
- (UIView *) settingsViewController:(id<IASKViewController>)settingsViewController
                          tableView:(UITableView *)tableView
            viewForFooterForSection:(NSInteger)section;

#pragma mark - UITableView cell customization
- (CGFloat)tableView:(UITableView*)tableView heightForSpecifier:(IASKSpecifier*)specifier;
- (UITableViewCell*)tableView:(UITableView*)tableView cellForSpecifier:(IASKSpecifier*)specifier;

#pragma mark - mail composing customization
- (BOOL)settingsViewController:(id<IASKViewController>)settingsViewController
shouldPresentMailComposeViewController:(MFMailComposeViewController*)mailComposeViewController
				  forSpecifier:(IASKSpecifier*) specifier;

- (NSString*) settingsViewController:(id<IASKViewController>)settingsViewController
		 mailComposeBodyForSpecifier:(IASKSpecifier*) specifier __deprecated_msg("Use settingsViewController:shouldPresentMailComposeViewController:forSpecifier: instead");

- (UIViewController<MFMailComposeViewControllerDelegate>*) settingsViewController:(id<IASKViewController>)settingsViewController
                                     viewControllerForMailComposeViewForSpecifier:(IASKSpecifier*)specifier __deprecated_msg("will be removed"); // let us know if you still need this, will be removed otherwise

- (void) settingsViewController:(id<IASKViewController>) settingsViewController
          mailComposeController:(MFMailComposeViewController*)controller
            didFinishWithResult:(MFMailComposeResult)result
                          error:(NSError*)error;

#pragma mark - Custom MultiValues
- (NSArray*)settingsViewController:(IASKAppSettingsViewController*)sender valuesForSpecifier:(IASKSpecifier*)specifier;
- (NSArray<NSString*>*)settingsViewController:(IASKAppSettingsViewController*)sender titlesForSpecifier:(IASKSpecifier*)specifier;

#pragma mark - respond to button taps
- (void)settingsViewController:(IASKAppSettingsViewController*)sender buttonTappedForKey:(NSString*)key __attribute__((deprecated)); // use the method below with specifier instead
- (void)settingsViewController:(IASKAppSettingsViewController*)sender buttonTappedForSpecifier:(IASKSpecifier*)specifier;
- (void)settingsViewController:(IASKAppSettingsViewController*)sender tableView:(UITableView *)tableView didSelectCustomViewSpecifier:(IASKSpecifier*)specifier;
@end


@interface IASKAppSettingsViewController : UITableViewController <IASKViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, weak, nullable) IBOutlet id<IASKSettingsDelegate> delegate;
@property (nonatomic, copy, null_resettable) NSString *file;

@property (nonatomic) BOOL showCreditsFooter;
@property (nonatomic) IBInspectable BOOL showDoneButton;
@property (nonatomic) IBInspectable BOOL neverShowPrivacySettings;
@property (nonatomic) IBInspectable BOOL cellLayoutMarginsFollowReadableWidth;


@property (nonatomic, copy) NSSet<NSString *> *hiddenKeys;
- (void)setHiddenKeys:(NSSet<NSString *> *)hiddenKeys animated:(BOOL)animated;


- (void)synchronizeSettings;

- (IBAction)dismiss:(nullable id)sender;

@end

NS_ASSUME_NONNULL_END
