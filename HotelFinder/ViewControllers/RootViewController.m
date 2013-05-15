//
//  RootViewController.m
//  HotelFinder
//
//  Created by Wang Shuguang on 13-5-13.
//  Copyright (c) 2013年 Dawn. All rights reserved.
//

#import "RootViewController.h"
#import "TopAuthWebView.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(20, 20, 60, 40);
    [button setTitle:@"请求" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(startRequest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *auth = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    auth.frame = CGRectMake(20, 80, 60, 40);
    [auth setTitle:@"授权" forState:UIControlStateNormal];
    [auth addTarget:self action:@selector(authRequest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:auth];
    
    userIdTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 200, 100, 20)];
    userIdTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:userIdTextField];
    [userIdTextField release];
}

- (void) authRequest{
    TopIOSClient *iosClient = [TopIOSClient getIOSClientByAppKey:APP_KEY];
    id result = [iosClient auth:self cb:@selector(authCallback:)];
    if ([result isMemberOfClass:[TopAuthWebViewToken class]]) {
        TopAuthWebView * view = [[TopAuthWebView alloc]initWithFrame:CGRectZero];
        [view open:result];
        UIViewController* c = [[[UIViewController alloc] init] autorelease];
        CGRect f = [[UIScreen mainScreen] applicationFrame];
        view.frame = CGRectMake(f.origin.x,40, f.size.width, f.size.height - 40);
        c.view = view;
        c.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain
                                                                              target:self action:@selector(closeAuthView)];
        c.navigationItem.title = @"授权";
        //显示层包装一下
        if (nc) {
            [nc release];
            nc = nil;
        }
        nc = [[[UINavigationController alloc]initWithRootViewController:c] autorelease];
        
        //弹出来
        [self presentModalViewController:nc animated:YES];
        [nc retain];
    }
}

-(void) authCallback:(id)data{
    if ([data isKindOfClass:[TopAuth class]]){
        TopAuth *auth = (TopAuth *)data;
        
        NSLog(@"%@",[auth user_id]);
        
        [userIdTextField setText:[auth user_id]];
        
    }
    else{
        NSLog(@"%@",data);
    }
    [self closeAuthView];
}

-(void)closeAuthView{
    [nc dismissModalViewControllerAnimated:YES];
    [nc release];
    nc = nil;
}

- (void) startRequest{
    //50011949
    //{"itemcats_get_response":{"item_cats":{"item_cat":[{"cid":50016161,"is_parent":false,"name":"酒店客栈","parent_cid":50011949},{"cid":50019784,"is_parent":true,"name":"酒店客栈套餐","parent_cid":50011949}]}}}
    
    TopIOSClient *iosClient =[TopIOSClient getIOSClientByAppKey:APP_KEY];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    /*
    [params setObject:@"taobao.itemprops.get" forKey:@"method"];
    [params setObject:@"pid,name,must,multi,prop_values" forKey:@"fields"];
    [params setObject:@"50016161" forKey:@"cid"];
    //[params setObject:@"6503015:52847" forKey:@"child_path"];
    //[params setObject:@"4618707:63595280" forKey:@"child_path"];
     */
    
    
    [params setObject:@"taobao.taobaoke.items.get" forKey:@"method"];
    [params setObject:@"num_iid,title,nick,pic_url,price,click_url,commission,commission_rate,commission_num,commission_volume,shop_click_url,seller_credit_score,item_location,volume" forKey:@"fields"];
    [params setObject:[@"c半缘君c" stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"nick"];
    [params setObject:@"北京" forKey:@"area"];
    [params setObject:@"50016161" forKey:@"cid"];
    [params setObject:@"1" forKey:@"page_no"];
    [params setObject:@"40" forKey:@"page_size"];
     
    
    //[params setObject:@"taobao.user.buyer.get" forKey:@"method"];
    //[params setObject:@"user_id,nick,sex,buyer_credit,avatar,has_shop,vip_info" forKey:@"fields"];


    [iosClient api:@"GET" params:params target:self cb:@selector(showApiResponse:) userId:@"c半缘君c" needMainThreadCallBack:true];
}


-(void)showApiResponse:(id)data
{
    if ([data isKindOfClass:[TopApiResponse class]]){
        TopApiResponse *response = (TopApiResponse *)data;
        
        if ([response content]){
            NSLog(@"%@",[response content]);
        }
        else {
            NSLog(@"%@",[(NSError *)[response error] userInfo]);
        }
        
        NSDictionary *dictionary = (NSDictionary *)[response reqParams];
        
        for (id key in dictionary) {
            
            NSLog(@"key: %@, value: %@", key, [dictionary objectForKey:key]);
            
        }
    }
    
}

@end
