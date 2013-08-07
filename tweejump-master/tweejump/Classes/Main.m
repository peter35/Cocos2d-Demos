#import "Main.h"
#import <mach/mach_time.h>

#define RANDOM_SEED() srandom((unsigned)(mach_absolute_time() & 0xFFFFFFFF))

@interface Main(Private)
- (void)initClouds;
- (void)initCloud;
@end

/*
 这里主要是底层背景、云朵的移动及复用
*/
@implementation Main

- (id)init {
//	NSLog(@"Main::init");
	
	if(![super init]) return nil;
	
	RANDOM_SEED();

    CCLOG(@"self.anchotPoint = %@",NSStringFromCGPoint(self.anchorPoint));//self.anchotPoint = {0.5, 0.5}
    //使用纹理关键要知道尺寸及偏移，用BatchNode是事先知道的，用Frame，则是保存在plist上的
	CCSpriteBatchNode *batchNode = [CCSpriteBatchNode batchNodeWithFile:@"sprites.png" capacity:10];//这里还只是初始化一个空的BatchNode，有点类似数组的初始化，图片这里是放到纹理缓存中渲染
	[self addChild:batchNode z:-1 tag:kSpriteManager];
    CCLOG(@"1 = %@",batchNode);
	CCSprite *background = [CCSprite spriteWithTexture:[batchNode texture] rect:CGRectMake(0,0,320,480)];
	[batchNode addChild:background];
    CCLOG(@"2 = %@",batchNode);

//    CCLOG(@"anchotPoint = %@",NSStringFromCGPoint(background.anchorPoint));
	background.position = CGPointMake(160,240);
//    CCLOG(@"position = %@",NSStringFromCGPoint(background.position));

	[self initClouds];

	[self schedule:@selector(step:)];
	
	return self;
}

- (void)dealloc {
//	NSLog(@"Main::dealloc");
	[super dealloc];
}

- (void)initClouds {//初始化 12 朵云
//	NSLog(@"initClouds");
	
	currentCloudTag = kCloudsStartTag;
	while(currentCloudTag < kCloudsStartTag + kNumClouds) {
		[self initCloud];
		currentCloudTag++;
	}
	
	[self resetClouds];
}

- (void)initCloud {
	
	CGRect rect;
	switch(random()%3) {
		case 0: rect = CGRectMake(336,16,256,108); break;
		case 1: rect = CGRectMake(336,128,257,110); break;
		case 2: rect = CGRectMake(336,240,252,119); break;
	}	
	
	CCSpriteBatchNode *batchNode = (CCSpriteBatchNode*)[self getChildByTag:kSpriteManager];
	CCSprite *cloud = [CCSprite spriteWithTexture:[batchNode texture] rect:rect];
	[batchNode addChild:cloud z:3 tag:currentCloudTag];
	
	cloud.opacity = 128;
}

- (void)resetClouds {//重置 12 朵云，包括大小，位置等
//	NSLog(@"resetClouds");
	
	currentCloudTag = kCloudsStartTag;
	
	while(currentCloudTag < kCloudsStartTag + kNumClouds) {
		[self resetCloud];

		CCSpriteBatchNode *batchNode = (CCSpriteBatchNode*)[self getChildByTag:kSpriteManager];
		CCSprite *cloud = (CCSprite*)[batchNode getChildByTag:currentCloudTag];
		CGPoint pos = cloud.position;
		pos.y -= 480.0f;
		cloud.position = pos;
		
		currentCloudTag++;
	}
}

- (void)resetCloud {
	
	CCSpriteBatchNode *batchNode = (CCSpriteBatchNode*)[self getChildByTag:kSpriteManager];
	CCSprite *cloud = (CCSprite*)[batchNode getChildByTag:currentCloudTag];
	
	float distance = random()%20 + 5;//5-25
	
    CCLOG(@"size1 = %@",NSStringFromCGSize(cloud.contentSize));
	float scale = 5.0f / distance;//0.04 - 1
	cloud.scaleX = scale;
	cloud.scaleY = scale;
	if(random()%2==1) cloud.scaleX = -cloud.scaleX;//反转
    CCLOG(@"size2 = %@",NSStringFromCGSize(cloud.contentSize));
	CGSize size = cloud.contentSize;
	float scaled_width = size.width * scale;
	float x = random()%(320+(int)scaled_width) - scaled_width/2;
	float y = random()%(480-(int)scaled_width) + scaled_width/2 + 480;
	
	cloud.position = ccp(x,y);
    CCLOG(@"size3 = %@",NSStringFromCGSize(cloud.contentSize));

}

- (void)step:(ccTime)dt {
//	NSLog(@"Main::step");
	
	CCSpriteBatchNode *batchNode = (CCSpriteBatchNode*)[self getChildByTag:kSpriteManager];
	
//	int t = kCloudsStartTag;
	for(int t = kCloudsStartTag; t < kCloudsStartTag + kNumClouds; t++) {
		CCSprite *cloud = (CCSprite*)[batchNode getChildByTag:t];
		CGPoint pos = cloud.position;
		CGSize size = cloud.contentSize;
		pos.x += 0.1f * cloud.scaleY;//水平移动的速率与缩放比例关联，这样效果上Cloud大（近）的移动的快，小（远）的移动的慢
		if(pos.x > 320 + size.width/2) {//刚好完全移出
			pos.x = -size.width/2;//位置重置到左边去
		}
		cloud.position = pos;
	}
	
}

@end
