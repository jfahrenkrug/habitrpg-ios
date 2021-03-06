//
//  HRPGAvatarSetupViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 30/09/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGAvatarSetupViewController.h"
#import "HRPGCustomizationSelectionView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIColor+Habitica.h"
#import "Customization.h"
#import "HRPGTaskSetupTableViewController.h"
#import "HRPGManager.h"
#import "HRPGAppDelegate.h"
#import "HRPGTypingLabel.h"
#import <Google/Analytics.h>

@interface HRPGAvatarSetupViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

@property UIImageView *justinView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;

@property UILabel *welcomeLabel;
@property HRPGTypingLabel *welcomeDescriptionLabel;
@property UILabel *descriptionlabel;
@property UILabel *skinInstructionlabel;
@property UILabel *shirtInstructionlabel;
@property UILabel *hairStyleInstructionlabel;
@property UILabel *hairColorInstructionlabel;

@property HRPGCustomizationSelectionView *skinSelectionView;
@property HRPGCustomizationSelectionView *shirtSelectionView;
@property UISegmentedControl *bodySizeView;
@property HRPGCustomizationSelectionView *hairBaseSelectionView;
@property HRPGCustomizationSelectionView *hairBangsSelectionView;
@property HRPGCustomizationSelectionView *hairColorSelectionView;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property UIButton *welcomeButton;

@property NSString *welcomeDescriptionString;
@property NSString *avatarDescriptionString;

@property BOOL isSkipping;

@end

@implementation HRPGAvatarSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    HRPGAppDelegate *appdelegate = (HRPGAppDelegate *) [[UIApplication sharedApplication] delegate];
    HRPGManager *manager = appdelegate.sharedManager;
    self.user = [manager getUser];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:NSStringFromClass([self class])];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    self.welcomeDescriptionString = NSLocalizedString(@"Welcome to Habitica, where advancing in the game will improve your real life! As you accomplish real-world goals, you'll unlock equipment, pets, quests, and more.", nil);
    self.avatarDescriptionString = NSLocalizedString(@"First, you need an avatar in the game to represent you! The things you do in real life will affect your avatar's health, experience level, and gold.", nil);
    
    switch (self.currentStep) {
        case HRPGAvatarSetupStepsWelcome:
            [self setupWelcomeStep];
            break;
        default:
            [self setupCustomizationStep];
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (!self.user) {
        HRPGAppDelegate *appdelegate = (HRPGAppDelegate *) [[UIApplication sharedApplication] delegate];
        HRPGManager *manager = appdelegate.sharedManager;
        self.user = [manager getUser];
    }
    
    if ([self.user.lastSetupStep integerValue] > self.currentStep) {
        self.isSkipping = YES;
        [self nextStep:nil];
    } else {
        self.isSkipping = NO;
        NSError *error;
        self.user.lastSetupStep = [NSNumber numberWithLong:self.currentStep];
        [self.managedObjectContext saveToPersistentStore:&error];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.currentStep == HRPGAvatarSetupStepsWelcome && self.welcomeDescriptionLabel.text.length == 0) {
        self.welcomeDescriptionLabel.text = self.welcomeDescriptionString;
    }
}

- (void)viewWillLayoutSubviews {
    CGFloat height;
    CGFloat labelWidth = self.mainScrollView.frame.size.width-40;
    if (labelWidth > 500) {
        labelWidth = 500;
    }
    if (self.currentStep == HRPGAvatarSetupStepsWelcome) {
            [super viewWillLayoutSubviews];
            self.justinView.frame = CGRectMake((self.mainScrollView.frame.size.width-84)/2, self.mainScrollView.frame.size.height/2-120, 84, 120);
            CGFloat descriptionHeight = [self.welcomeDescriptionString boundingRectWithSize:CGSizeMake(labelWidth, MAXFLOAT)
                                                                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                                                                 attributes:@{
                                                                                                              NSFontAttributeName : [UIFont systemFontOfSize:16.0]
                                                                                                              }
                                                                                                    context:nil].size.height+10;
            self.welcomeLabel.frame = CGRectMake(0, self.justinView.frame.origin.y - 50, self.mainScrollView.frame.size.width, 30);
            self.welcomeDescriptionLabel.frame = CGRectMake((self.mainScrollView.frame.size.width-labelWidth)/2, self.justinView.frame.origin.y+160, labelWidth, descriptionHeight);
            self.welcomeButton.frame = CGRectMake(20, self.welcomeDescriptionLabel.frame.origin.y+descriptionHeight+20, self.mainScrollView.frame.size.width-20, 60);
            height = self.welcomeButton.frame.origin.y+self.welcomeButton.frame.size.height;
        } else {
            CGFloat descriptionHeight = [self.avatarDescriptionString boundingRectWithSize:CGSizeMake(labelWidth, MAXFLOAT)
                                                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                                                attributes:@{
                                                                                             NSFontAttributeName : [UIFont systemFontOfSize:16.0]
                                                                                             }
                                                                                   context:nil].size.height+10;
            self.descriptionlabel.frame = CGRectMake((self.mainScrollView.frame.size.width-labelWidth)/2, 0, labelWidth, descriptionHeight);
            
            CGFloat skinInstructionHeight = [self.skinInstructionlabel.text boundingRectWithSize:CGSizeMake(labelWidth, MAXFLOAT)
                                                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                                                      attributes:@{
                                                                                                   NSFontAttributeName : [UIFont systemFontOfSize:16.0]
                                                                                                   }
                                                                                         context:nil].size.height+10;
            self.skinInstructionlabel.frame = CGRectMake((self.mainScrollView.frame.size.width-labelWidth)/2, self.descriptionlabel.frame.origin.y+self.descriptionlabel.frame.size.height+30, labelWidth, skinInstructionHeight);
            self.skinSelectionView.frame = CGRectMake(20, self.skinInstructionlabel.frame.origin.y+self.skinInstructionlabel.frame.size.height+10, self.mainScrollView.frame.size.width-40, 250);
            [self.skinSelectionView layoutSubviews];
            [self.skinSelectionView sizeToFit];
            
            CGFloat shirtInstructionHeight = [self.shirtInstructionlabel.text boundingRectWithSize:CGSizeMake(labelWidth, MAXFLOAT)
                                                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                                                      attributes:@{
                                                                                                   NSFontAttributeName : [UIFont systemFontOfSize:16.0]
                                                                                                   }
                                                                                         context:nil].size.height+10;
            self.shirtInstructionlabel.frame = CGRectMake((self.mainScrollView.frame.size.width-labelWidth)/2, self.skinSelectionView.frame.origin.y+self.skinSelectionView.frame.size.height+30, labelWidth, shirtInstructionHeight);
            self.shirtSelectionView.frame = CGRectMake(20, self.shirtInstructionlabel.frame.origin.y+self.shirtInstructionlabel.frame.size.height+10, self.mainScrollView.frame.size.width-40, 250);
            [self.shirtSelectionView layoutSubviews];
            [self.shirtSelectionView sizeToFit];
            self.bodySizeView.frame = CGRectMake((self.mainScrollView.frame.size.width/2)-50, self.shirtSelectionView.frame.origin.y+self.shirtSelectionView.frame.size.height+10, 100, 30);
            
            CGFloat hairStyleInstructionHeight = [self.hairStyleInstructionlabel.text boundingRectWithSize:CGSizeMake(labelWidth, MAXFLOAT)
                                                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                                                        attributes:@{
                                                                                                     NSFontAttributeName : [UIFont systemFontOfSize:16.0]
                                                                                                     }
                                                                                           context:nil].size.height+10;
            self.hairStyleInstructionlabel.frame = CGRectMake((self.mainScrollView.frame.size.width-labelWidth)/2, self.bodySizeView.frame.origin.y+self.bodySizeView.frame.size.height+30, labelWidth, hairStyleInstructionHeight);
            self.hairBaseSelectionView.frame = CGRectMake(20, self.hairStyleInstructionlabel.frame.origin.y+self.hairStyleInstructionlabel.frame.size.height+10, self.mainScrollView.frame.size.width-40, 250);
            [self.hairBaseSelectionView layoutSubviews];
            [self.hairBaseSelectionView sizeToFit];
            self.hairBangsSelectionView.frame = CGRectMake(20, self.hairBaseSelectionView.frame.origin.y+self.hairBaseSelectionView.frame.size.height+20, self.mainScrollView.frame.size.width-40, 250);
            [self.hairBangsSelectionView layoutSubviews];
            [self.hairBangsSelectionView sizeToFit];
            
            CGFloat hairColorInstructionHeight = [self.hairColorInstructionlabel.text boundingRectWithSize:CGSizeMake(labelWidth, MAXFLOAT)
                                                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                                                      attributes:@{
                                                                                                   NSFontAttributeName : [UIFont systemFontOfSize:16.0]
                                                                                                   }
                                                                                         context:nil].size.height+10;
            self.hairColorInstructionlabel.frame = CGRectMake((self.mainScrollView.frame.size.width-labelWidth)/2, self.hairBangsSelectionView.frame.origin.y+self.hairBangsSelectionView.frame.size.height+30, labelWidth, hairColorInstructionHeight);
            self.hairColorSelectionView.frame = CGRectMake(20, self.hairColorInstructionlabel.frame.origin.y+self.hairColorInstructionlabel.frame.size.height+10, self.mainScrollView.frame.size.width-40, 250);
            [self.hairColorSelectionView layoutSubviews];
            [self.hairColorSelectionView sizeToFit];
            
            height = self.hairColorSelectionView.frame.origin.y+self.hairColorSelectionView.frame.size.height;
    }
    [super viewWillLayoutSubviews];
    CGSize oldContentSize = self.mainScrollView.contentSize;
    oldContentSize.height = height;
    self.mainScrollView.contentSize = oldContentSize;
}

- (void)setupWelcomeStep {
    self.backButton.hidden = YES;
    self.nextButton.hidden = YES;
    
    self.welcomeLabel = [[UILabel alloc] init];
    self.welcomeLabel.font = [UIFont systemFontOfSize:26.0];
    self.welcomeLabel.textAlignment = NSTextAlignmentCenter;
    self.welcomeLabel.text = NSLocalizedString(@"Welcome", nil);
    [self.mainScrollView addSubview:self.welcomeLabel];
    
    self.justinView = [[UIImageView alloc] init];
    self.justinView.image = [UIImage imageNamed:@"justin"];
    [self.mainScrollView addSubview:self.justinView];
    
    self.welcomeDescriptionLabel = [[HRPGTypingLabel alloc] init];
    self.welcomeDescriptionLabel.textAlignment = NSTextAlignmentLeft;
    self.welcomeDescriptionLabel.font = [UIFont systemFontOfSize:16.0];
    [self.mainScrollView addSubview:self.welcomeDescriptionLabel];
    
    self.welcomeButton = [[UIButton alloc] init];
    [self.welcomeButton setTitle:NSLocalizedString(@"Enter", nil) forState:UIControlStateNormal];
    [self.welcomeButton setTitleColor:[UIColor purple400] forState:UIControlStateNormal];
    [self.welcomeButton addTarget:self action:@selector(nextStep:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainScrollView addSubview:self.welcomeButton];
}

- (void) setupCustomizationStep {
    [self.user setAvatarOnImageView:self.avatarView withPetMount:NO onlyHead:NO withBackground:NO useForce:NO];
    self.avatarView.contentMode = UIViewContentModeCenter;
    self.avatarView.userInteractionEnabled = NO;
    __weak HRPGAvatarSetupViewController *weakSelf = self;
    
    self.descriptionlabel = [[UILabel alloc] init];
    self.descriptionlabel.numberOfLines = 0;
    self.descriptionlabel.text = self.avatarDescriptionString;
    [self.mainScrollView addSubview:self.descriptionlabel];
    
    self.skinInstructionlabel = [[UILabel alloc] init];
    self.skinInstructionlabel.numberOfLines = 0;
    self.skinInstructionlabel.textAlignment = NSTextAlignmentCenter;
    self.skinInstructionlabel.text = NSLocalizedString(@"Choose a skin color!", nil);
    [self.mainScrollView addSubview:self.skinInstructionlabel];
    self.skinSelectionView = [[HRPGCustomizationSelectionView alloc] init];
    self.skinSelectionView.verticalCutoff = 0.85;
    self.skinSelectionView.user = self.user;
    self.skinSelectionView.selectedItem = self.user.skin;
    self.skinSelectionView.items = [self getCustomizationsWithPredicate:[NSPredicate predicateWithFormat:@"price == 0 && type == 'skin'"]];
    self.skinSelectionView.selectionAction = ^(Customization *selectedItem) {
        weakSelf.user.skin = selectedItem.name;
        [weakSelf.user setAvatarOnImageView:weakSelf.avatarView withPetMount:NO onlyHead:NO withBackground:NO useForce:YES];
    };
    [self.mainScrollView addSubview:self.skinSelectionView];
    
    self.shirtInstructionlabel = [[UILabel alloc] init];
    self.shirtInstructionlabel.numberOfLines = 0;
    self.shirtInstructionlabel.textAlignment = NSTextAlignmentCenter;
    self.shirtInstructionlabel.text = NSLocalizedString(@"Choose your outfit! (You'll unlock more outfits soon.)", nil);
    [self.mainScrollView addSubview:self.shirtInstructionlabel];
    self.shirtSelectionView = [[HRPGCustomizationSelectionView alloc] init];
    self.shirtSelectionView.verticalCutoff = 1.1;
    self.shirtSelectionView.user = self.user;
    self.shirtSelectionView.selectedItem = self.user.shirt;
    self.shirtSelectionView.items = [self getCustomizationsWithPredicate:[NSPredicate predicateWithFormat:@"price == 0 && type == 'shirt'"]];
    self.shirtSelectionView.selectionAction = ^(Customization *selectedItem) {
        weakSelf.user.shirt = selectedItem.name;
        [weakSelf.user setAvatarOnImageView:weakSelf.avatarView withPetMount:NO onlyHead:NO withBackground:NO useForce:YES];
    };
    [self.mainScrollView addSubview:self.shirtSelectionView];
    self.bodySizeView = [[UISegmentedControl alloc] initWithItems:@[@"Slim", @"Broad"]];
    [self.mainScrollView addSubview:self.bodySizeView];
    if ([self.user.size isEqualToString:@"slim"]) {
        [self.bodySizeView setSelectedSegmentIndex:0];
    } else {
        [self.bodySizeView setSelectedSegmentIndex:1];
    }
    [self.bodySizeView addTarget:self action:@selector(userSizeChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    self.hairStyleInstructionlabel = [[UILabel alloc] init];
    self.hairStyleInstructionlabel.numberOfLines = 0;
    self.hairStyleInstructionlabel.textAlignment = NSTextAlignmentCenter;
    self.hairStyleInstructionlabel.text = NSLocalizedString(@"Choose a hairstyle!", nil);
    [self.mainScrollView addSubview:self.hairStyleInstructionlabel];
    self.hairBaseSelectionView = [[HRPGCustomizationSelectionView alloc] init];
    self.hairBaseSelectionView.verticalCutoff = 0.85;
    self.hairBaseSelectionView.user = self.user;
    self.hairBaseSelectionView.selectedItem = self.user.hairBase;
    self.hairBaseSelectionView.items = [self getCustomizationsWithPredicate:[NSPredicate predicateWithFormat:@"price == 0 && type == 'hair' && group == 'base'"]];
    self.hairBaseSelectionView.selectionAction = ^(Customization *selectedItem) {
        weakSelf.user.hairBase = selectedItem.name;
        [weakSelf.user setAvatarOnImageView:weakSelf.avatarView withPetMount:NO onlyHead:NO withBackground:NO useForce:YES];
    };
    [self.mainScrollView addSubview:self.hairBaseSelectionView];
    self.hairBangsSelectionView = [[HRPGCustomizationSelectionView alloc] init];
    self.hairBangsSelectionView.verticalCutoff = 0.85;
    self.hairBangsSelectionView.user = self.user;
    self.hairBangsSelectionView.selectedItem = self.user.hairBangs;
    self.hairBangsSelectionView.items = [self getCustomizationsWithPredicate:[NSPredicate predicateWithFormat:@"price == 0 && type == 'hair' && group == 'bangs'"]];
    self.hairBangsSelectionView.selectionAction = ^(Customization *selectedItem) {
        weakSelf.user.hairBangs = selectedItem.name;
        [weakSelf.user setAvatarOnImageView:weakSelf.avatarView withPetMount:NO onlyHead:NO withBackground:NO useForce:YES];
    };
    [self.mainScrollView addSubview:self.hairBangsSelectionView];
    
    self.hairColorInstructionlabel = [[UILabel alloc] init];
    self.hairColorInstructionlabel.numberOfLines = 0;
    self.hairColorInstructionlabel.textAlignment = NSTextAlignmentCenter;
    self.hairColorInstructionlabel.text = NSLocalizedString(@"Choose a hair color!", nil);
    [self.mainScrollView addSubview:self.hairColorInstructionlabel];
    self.hairColorSelectionView = [[HRPGCustomizationSelectionView alloc] init];
    self.hairColorSelectionView.verticalCutoff = 0.77;
    self.hairColorSelectionView.user = self.user;
    self.hairColorSelectionView.selectedItem = self.user.hairColor;
    self.hairColorSelectionView.items = [self getCustomizationsWithPredicate:[NSPredicate predicateWithFormat:@"price == 0 && type == 'hair' && group == 'color'"]];
    self.hairColorSelectionView.selectionAction = ^(Customization *selectedItem) {
        weakSelf.user.hairColor = selectedItem.name;
        [weakSelf.user setAvatarOnImageView:weakSelf.avatarView withPetMount:NO onlyHead:NO withBackground:NO useForce:YES];
    };
    [self.mainScrollView addSubview:self.hairColorSelectionView];
}

- (IBAction)nextStep:(id)sender {
    NSError *error;
    [self.managedObjectContext saveToPersistentStore:&error];
    
    NSDictionary *updateDict;
    switch (self.currentStep) {
        case HRPGAvatarSetupStepsAvatar:
            updateDict = @{@"preferences.skin": self.user.skin, @"preferences.shirt": self.user.shirt, @"preferences.size": self.user.size, @"preferences.hair.base": self.user.hairBase, @"preferences.hair.bangs": self.user.hairBangs, @"preferences.hair.color": self.user.hairColor};
            break;
    }
    HRPGAppDelegate *appdelegate = (HRPGAppDelegate *) [[UIApplication sharedApplication] delegate];
    HRPGManager *manager = appdelegate.sharedManager;
    [manager updateUser:updateDict onSuccess:^() {
        
    }onError:^() {
        
    }];
    
    if (self.currentStep != HRPGAvatarSetupStepsAvatar) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        HRPGAvatarSetupViewController *dest = [storyboard instantiateViewControllerWithIdentifier:@"AvatarSetupViewController"];
        dest.currentStep = self.currentStep+1;
        dest.user = self.user;
        dest.managedObjectContext = self.managedObjectContext;
        [self.navigationController pushViewController:dest animated:!self.isSkipping];
    } else {
        [self performSegueWithIdentifier:@"TaskSetupSegue" sender:self];
    }
}


- (IBAction)previousStep:(id)sender {
    self.user.lastSetupStep = [NSNumber numberWithInteger:self.currentStep-1];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)skipSetup:(id)sender {
    self.user.lastSetupStep = [NSNumber numberWithInteger:HRPGAvatarSetupStepsTasks];
    NSError *error;
    [self.managedObjectContext saveToPersistentStore:&error];
    [self performSegueWithIdentifier:@"MainSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"TaskSetupSegue"]) {
        HRPGTaskSetupTableViewController *destinationController = segue.destinationViewController;
        destinationController.user = self.user;
        destinationController.managedObjectContext = self.managedObjectContext;
        destinationController.currentStep = HRPGAvatarSetupStepsTasks;
    }
}

- (IBAction)userSizeChanged:(UISegmentedControl*)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.user.size = @"slim";
    } else {
        self.user.size = @"broad";
    }
    [self.user setAvatarOnImageView:self.avatarView withPetMount:NO onlyHead:NO withBackground:NO useForce:YES];

}

- (NSArray *)getCustomizationsWithPredicate:(NSPredicate *)predicate {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Customization" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    NSError *error;
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

@end
