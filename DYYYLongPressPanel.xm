#import "AwemeHeaders.h"
#import "DYYYBottomAlertView.h"
#import "DYYYConfirmCloseView.h"
#import "DYYYCustomInputView.h"
#import "DYYYFilterSettingsView.h"
#import "DYYYKeywordListView.h"
#import "DYYYManager.h"
#import "DYYYToast.h"
#import "DYYYUtils.h"

%hook AWELongPressPanelViewGroupModel
%property(nonatomic, assign) BOOL isDYYYCustomGroup;
%end

// Modern风格长按面板（新版UI）
%hook AWEModernLongPressPanelTableViewController
- (NSArray *)dataArray {
	NSArray *originalArray = %orig;
	if (!originalArray) {
		originalArray = @[];
	}

	// 检查是否启用了任意长按功能
	BOOL hasAnyFeatureEnabled = NO;
	// 检查各个单独的功能开关
	BOOL enableSaveVideo = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYLongPressSaveVideo"];
	BOOL enableSaveCover = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYLongPressSaveCover"];
	BOOL enableSaveAudio = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYLongPressSaveAudio"];
	BOOL enableSaveCurrentImage = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYLongPressSaveCurrentImage"];
	BOOL enableSaveAllImages = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYLongPressSaveAllImages"];
	BOOL enableCopyText = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYLongPressCopyText"];
	BOOL enableCopyLink = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYLongPressCopyLink"];
	BOOL enableApiDownload = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYLongPressApiDownload"];
	BOOL enableFilterUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYLongPressFilterUser"];
	BOOL enableFilterKeyword = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYLongPressFilterTitle"];
	BOOL enableTimerClose = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYLongPressTimerClose"];
	BOOL enableCreateVideo = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYLongPressCreateVideo"];

	// 检查是否有任何功能启用
	hasAnyFeatureEnabled = enableSaveVideo || enableSaveCover || enableSaveAudio || enableSaveCurrentImage || enableSaveAllImages || enableCopyText || enableCopyLink || enableApiDownload ||
			       enableFilterUser || enableFilterKeyword || enableTimerClose || enableCreateVideo;

	// 获取需要隐藏的按钮设置
	BOOL hideDaily = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelDaily"];
	BOOL hideRecommend = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelRecommend"];
	BOOL hideNotInterested = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelNotInterested"];
	BOOL hideReport = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelReport"];
	BOOL hideSpeed = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelSpeed"];
	BOOL hideClearScreen = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelClearScreen"];
	BOOL hideFavorite = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelFavorite"];
	BOOL hideLater = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelLater"];
	BOOL hideCast = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelCast"];
	BOOL hideOpenInPC = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelOpenInPC"];
	BOOL hideSubtitle = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelSubtitle"];
	BOOL hideAutoPlay = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelAutoPlay"];
	BOOL hideSearchImage = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelSearchImage"];
	BOOL hideListenDouyin = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelListenDouyin"];
	BOOL hideBackgroundPlay = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelBackgroundPlay"];
	BOOL hideBiserial = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelBiserial"];
	BOOL hideTimerclose = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelTimerClose"];

	// 存储处理后的原始组
	NSMutableArray *modifiedOriginalGroups = [NSMutableArray array];

	// 处理原始面板，收集所有未被隐藏的官方按钮
	for (id group in originalArray) {
		if ([group isKindOfClass:%c(AWELongPressPanelViewGroupModel)]) {
			AWELongPressPanelViewGroupModel *groupModel = (AWELongPressPanelViewGroupModel *)group;
			NSMutableArray *filteredGroupArr = [NSMutableArray array];

			for (id item in groupModel.groupArr) {
				if ([item isKindOfClass:%c(AWELongPressPanelBaseViewModel)]) {
					AWELongPressPanelBaseViewModel *viewModel = (AWELongPressPanelBaseViewModel *)item;
					NSString *descString = viewModel.describeString;
					// 根据描述字符串判断按钮类型并决定是否保留
					BOOL shouldHide = NO;
					if ([descString isEqualToString:@"转发到日常"] && hideDaily) {
						shouldHide = YES;
					} else if (([descString isEqualToString:@"推荐"] || [descString isEqualToString:@"取消推荐"]) && hideRecommend) {
						shouldHide = YES;
					} else if ([descString isEqualToString:@"不感兴趣"] && hideNotInterested) {
						shouldHide = YES;
					} else if ([descString isEqualToString:@"举报"] && hideReport) {
						shouldHide = YES;
					} else if ([descString isEqualToString:@"倍速"] && hideSpeed) {
						shouldHide = YES;
					} else if ([descString isEqualToString:@"清屏播放"] && hideClearScreen) {
						shouldHide = YES;
					} else if ([descString isEqualToString:@"缓存视频"] && hideFavorite) {
						shouldHide = YES;
					} else if ([descString isEqualToString:@"添加至稍后再看"] && hideLater) {
						shouldHide = YES;
					} else if ([descString isEqualToString:@"投屏"] && hideCast) {
						shouldHide = YES;
					} else if ([descString isEqualToString:@"电脑/Pad打开"] && hideOpenInPC) {
						shouldHide = YES;
					} else if ([descString isEqualToString:@"弹幕"] && hideSubtitle) {
						shouldHide = YES;
					} else if ([descString isEqualToString:@"弹幕开关"] && hideSubtitle) {
						shouldHide = YES;
					} else if ([descString isEqualToString:@"弹幕设置"] && hideSubtitle) {
						shouldHide = YES;
					} else if ([descString isEqualToString:@"自动连播"] && hideAutoPlay) {
						shouldHide = YES;
					} else if ([descString isEqualToString:@"识别图片"] && hideSearchImage) {
						shouldHide = YES;
					} else if (([descString isEqualToString:@"听抖音"] || [descString isEqualToString:@"后台听"] || [descString isEqualToString:@"听视频"]) && hideListenDouyin) {
						shouldHide = YES;
					} else if ([descString isEqualToString:@"后台播放设置"] && hideBackgroundPlay) {
						shouldHide = YES;
					} else if ([descString isEqualToString:@"首页双列快捷入口"] && hideBiserial) {
						shouldHide = YES;
					} else if ([descString isEqualToString:@"定时关闭"] && hideTimerclose) {
						shouldHide = YES;
					}

					if (!shouldHide) {
						[filteredGroupArr addObject:viewModel];
					}
				}
			}

			// 如果过滤后的组不为空，则保存原始组结构
			if (filteredGroupArr.count > 0) {
				AWELongPressPanelViewGroupModel *newGroup = [[%c(AWELongPressPanelViewGroupModel) alloc] init];
				newGroup.isDYYYCustomGroup = YES;
				newGroup.groupType = groupModel.groupType;
				newGroup.isModern = YES;
				newGroup.groupArr = filteredGroupArr;
				[modifiedOriginalGroups addObject:newGroup];
			}
		}
	}

	// 如果没有任何功能启用，仅使用官方按钮
	if (!hasAnyFeatureEnabled) {
		// 直接返回修改后的原始组
		return modifiedOriginalGroups;
	}

	// 创建自定义功能按钮
	NSMutableArray *viewModels = [NSMutableArray array];

	BOOL isNewLivePhoto = (self.awemeModel.video && self.awemeModel.animatedImageVideoInfo != nil);

	// 视频下载功能 (非实况照片才显示)
	if (enableSaveVideo && self.awemeModel.awemeType != 68 && !isNewLivePhoto) {
		AWELongPressPanelBaseViewModel *downloadViewModel = [[%c(AWELongPressPanelBaseViewModel) alloc] init];
		downloadViewModel.awemeModel = self.awemeModel;
		downloadViewModel.actionType = 666;
		downloadViewModel.duxIconName = @"ic_boxarrowdownhigh_outlined";
		downloadViewModel.describeString = @"保存视频";
		downloadViewModel.action = ^{
		  AWEAwemeModel *awemeModel = self.awemeModel;
		  AWEVideoModel *videoModel = awemeModel.video;

		  if (videoModel && videoModel.bitrateModels && videoModel.bitrateModels.count > 0) {
			  // 优先使用bitrateModels中的最高质量版本
			  id highestQualityModel = videoModel.bitrateModels.firstObject;
			  NSArray *urlList = nil;
			  id playAddrObj = [highestQualityModel valueForKey:@"playAddr"];

			  if ([playAddrObj isKindOfClass:%c(AWEURLModel)]) {
				  AWEURLModel *playAddrModel = (AWEURLModel *)playAddrObj;
				  urlList = playAddrModel.originURLList;
			  }

			  if (urlList && urlList.count > 0) {
				  NSURL *url = [NSURL URLWithString:urlList.firstObject];
				  [DYYYManager downloadMedia:url
						   mediaType:MediaTypeVideo
						  completion:^(BOOL success){
						  }];
			  } else {
				  // 备用方法：直接使用h264URL
				  if (videoModel.h264URL && videoModel.h264URL.originURLList.count > 0) {
					  NSURL *url = [NSURL URLWithString:videoModel.h264URL.originURLList.firstObject];
					  [DYYYManager downloadMedia:url
							   mediaType:MediaTypeVideo
							  completion:^(BOOL success){
							  }];
				  }
			  }
		  }
		  AWELongPressPanelManager *panelManager = [%c(AWELongPressPanelManager) shareInstance];
		  [panelManager dismissWithAnimation:YES completion:nil];
		};
		[viewModels addObject:downloadViewModel];
	}

	//  新版实况照片保存
	if (enableSaveVideo && self.awemeModel.awemeType != 68 && isNewLivePhoto) {
		AWELongPressPanelBaseViewModel *livePhotoViewModel = [[%c(AWELongPressPanelBaseViewModel) alloc] init];
		livePhotoViewModel.awemeModel = self.awemeModel;
		livePhotoViewModel.actionType = 679;
		livePhotoViewModel.duxIconName = @"ic_boxarrowdownhigh_outlined";
		livePhotoViewModel.describeString = @"保存实况";
		livePhotoViewModel.action = ^{
		  AWEAwemeModel *awemeModel = self.awemeModel;
		  AWEVideoModel *videoModel = awemeModel.video;

		  // 使用封面URL作为图片URL
		  NSURL *imageURL = nil;
		  if (videoModel.coverURL && videoModel.coverURL.originURLList.count > 0) {
			  imageURL = [NSURL URLWithString:videoModel.coverURL.originURLList.firstObject];
		  }

		  // 视频URL从视频模型获取
		  NSURL *videoURL = nil;
		  if (videoModel && videoModel.playURL && videoModel.playURL.originURLList.count > 0) {
			  videoURL = [NSURL URLWithString:videoModel.playURL.originURLList.firstObject];
		  } else if (videoModel && videoModel.h264URL && videoModel.h264URL.originURLList.count > 0) {
			  videoURL = [NSURL URLWithString:videoModel.h264URL.originURLList.firstObject];
		  }

		  // 下载实况照片
		  if (imageURL && videoURL) {
			  [DYYYManager downloadLivePhoto:imageURL
						videoURL:videoURL
					      completion:^{
					      }];
		  }

		  AWELongPressPanelManager *panelManager = [%c(AWELongPressPanelManager) shareInstance];
		  [panelManager dismissWithAnimation:YES completion:nil];
		};
		[viewModels addObject:livePhotoViewModel];
	}

	// 当前图片/实况下载功能
	if (enableSaveCurrentImage && self.awemeModel.awemeType == 68 && self.awemeModel.albumImages.count > 0) {
		AWELongPressPanelBaseViewModel *imageViewModel = [[%c(AWELongPressPanelBaseViewModel) alloc] init];
		imageViewModel.awemeModel = self.awemeModel;
		imageViewModel.actionType = 669;
		imageViewModel.duxIconName = @"ic_boxarrowdownhigh_outlined";

		if (self.awemeModel.albumImages.count == 1) {
			imageViewModel.describeString = @"保存图片";
		} else {
			imageViewModel.describeString = @"保存当前图片";
		}

		AWEImageAlbumImageModel *currimge = self.awemeModel.albumImages[self.awemeModel.currentImageIndex - 1];
		if (currimge.clipVideo != nil || self.awemeModel.isLivePhoto) {
			if (self.awemeModel.albumImages.count == 1) {
				imageViewModel.describeString = @"保存实况";
			} else {
				imageViewModel.describeString = @"保存当前实况";
			}
		}
		imageViewModel.action = ^{
		  AWEAwemeModel *awemeModel = self.awemeModel;
		  AWEImageAlbumImageModel *currentImageModel = nil;
		  if (awemeModel.currentImageIndex > 0 && awemeModel.currentImageIndex <= awemeModel.albumImages.count) {
			  currentImageModel = awemeModel.albumImages[awemeModel.currentImageIndex - 1];
		  } else {
			  currentImageModel = awemeModel.albumImages.firstObject;
		  }
		  // 如果是实况的话
		  // 查找非.image后缀的URL
		  NSURL *downloadURL = nil;
		  for (NSString *urlString in currentImageModel.urlList) {
			  NSURL *url = [NSURL URLWithString:urlString];
			  NSString *pathExtension = [url.path.lowercaseString pathExtension];
			  if (![pathExtension isEqualToString:@"image"]) {
				  downloadURL = url;
				  break;
			  }
		  }

		  if (currentImageModel.clipVideo != nil) {
			  NSURL *videoURL = [currentImageModel.clipVideo.playURL getDYYYSrcURLDownload];
			  [DYYYManager downloadLivePhoto:downloadURL
						videoURL:videoURL
					      completion:^{
					      }];
		  } else if (currentImageModel && currentImageModel.urlList.count > 0) {
			  if (downloadURL) {
				  [DYYYManager downloadMedia:downloadURL
						   mediaType:MediaTypeImage
						  completion:^(BOOL success) {
						    if (success) {
						    } else {
							    [DYYYUtils showToast:@"图片保存已取消"];
						    }
						  }];
			  } else {
				  [DYYYUtils showToast:@"没有找到合适格式的图片"];
			  }
		  }
		  AWELongPressPanelManager *panelManager = [%c(AWELongPressPanelManager) shareInstance];
		  [panelManager dismissWithAnimation:YES completion:nil];
		};
		[viewModels addObject:imageViewModel];
	}

	// 保存所有图片/实况功能
	if (enableSaveAllImages && self.awemeModel.awemeType == 68 && self.awemeModel.albumImages.count > 1) {
		AWELongPressPanelBaseViewModel *allImagesViewModel = [[%c(AWELongPressPanelBaseViewModel) alloc] init];
		allImagesViewModel.awemeModel = self.awemeModel;
		allImagesViewModel.actionType = 670;
		allImagesViewModel.duxIconName = @"ic_boxarrowdownhigh_outlined";
		allImagesViewModel.describeString = @"保存所有图片";
		// 检查是否有实况照片并更改按钮文字
		BOOL hasLivePhoto = NO;
		for (AWEImageAlbumImageModel *imageModel in self.awemeModel.albumImages) {
			if (imageModel.clipVideo != nil) {
				hasLivePhoto = YES;
				break;
			}
		}
		if (hasLivePhoto) {
			allImagesViewModel.describeString = @"保存所有实况";
		}
		allImagesViewModel.action = ^{
		  AWEAwemeModel *awemeModel = self.awemeModel;
		  NSMutableArray *imageURLs = [NSMutableArray array];
		  NSMutableArray *livePhotos = [NSMutableArray array];

		  for (AWEImageAlbumImageModel *imageModel in awemeModel.albumImages) {
			  if (imageModel.urlList.count > 0) {
				  // 查找非.image后缀的URL
				  NSURL *downloadURL = nil;
				  for (NSString *urlString in imageModel.urlList) {
					  NSURL *url = [NSURL URLWithString:urlString];
					  NSString *pathExtension = [url.path.lowercaseString pathExtension];
					  if (![pathExtension isEqualToString:@"image"]) {
						  downloadURL = url;
						  break;
					  }
				  }

				  if (!downloadURL && imageModel.urlList.count > 0) {
					  downloadURL = [NSURL URLWithString:imageModel.urlList.firstObject];
				  }

				  // 检查是否是实况照片
				  if (imageModel.clipVideo != nil) {
					  NSURL *videoURL = [imageModel.clipVideo.playURL getDYYYSrcURLDownload];
					  [livePhotos addObject:@{@"imageURL" : downloadURL.absoluteString, @"videoURL" : videoURL.absoluteString}];
				  } else {
					  [imageURLs addObject:downloadURL.absoluteString];
				  }
			  }
		  }

		  // 分别处理普通图片和实况照片
		  if (livePhotos.count > 0) {
			  [DYYYManager downloadAllLivePhotos:livePhotos];
		  }

		  if (imageURLs.count > 0) {
			  [DYYYManager downloadAllImages:imageURLs];
		  }

		  if (livePhotos.count == 0 && imageURLs.count == 0) {
			  [DYYYUtils showToast:@"没有找到合适格式的图片"];
		  }

		  AWELongPressPanelManager *panelManager = [%c(AWELongPressPanelManager) shareInstance];
		  [panelManager dismissWithAnimation:YES completion:nil];
		};
		[viewModels addObject:allImagesViewModel];
	}

	// 接口保存功能
	NSString *apiKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYInterfaceDownload"];
	if (enableApiDownload && apiKey.length > 0) {
		AWELongPressPanelBaseViewModel *apiDownload = [[%c(AWELongPressPanelBaseViewModel) alloc] init];
		apiDownload.awemeModel = self.awemeModel;
		apiDownload.actionType = 673;
		apiDownload.duxIconName = @"ic_cloudarrowdown_outlined_20";
		apiDownload.describeString = @"接口保存";
		apiDownload.action = ^{
		  NSString *shareLink = [self.awemeModel valueForKey:@"shareURL"];
		  if (shareLink.length == 0) {
			  [DYYYUtils showToast:@"无法获取分享链接"];
			  return;
		  }
		  // 使用封装的方法进行解析下载
		  [DYYYManager parseAndDownloadVideoWithShareLink:shareLink apiKey:apiKey];
		  AWELongPressPanelManager *panelManager = [%c(AWELongPressPanelManager) shareInstance];
		  [panelManager dismissWithAnimation:YES completion:nil];
		};
		[viewModels addObject:apiDownload];
	}

	// 封面下载功能
	if (enableSaveCover && self.awemeModel.awemeType != 68) {
		AWELongPressPanelBaseViewModel *coverViewModel = [[%c(AWELongPressPanelBaseViewModel) alloc] init];
		coverViewModel.awemeModel = self.awemeModel;
		coverViewModel.actionType = 667;
		coverViewModel.duxIconName = @"ic_boxarrowdownhigh_outlined";
		coverViewModel.describeString = @"保存封面";
		coverViewModel.action = ^{
		  AWEAwemeModel *awemeModel = self.awemeModel;
		  AWEVideoModel *videoModel = awemeModel.video;
		  if (videoModel && videoModel.coverURL && videoModel.coverURL.originURLList.count > 0) {
			  NSURL *url = [NSURL URLWithString:videoModel.coverURL.originURLList.firstObject];
			  [DYYYManager downloadMedia:url
					   mediaType:MediaTypeImage
					  completion:^(BOOL success) {
					    if (success) {
					    } else {
						    [DYYYUtils showToast:@"封面保存已取消"];
					    }
					  }];
		  }
		  AWELongPressPanelManager *panelManager = [%c(AWELongPressPanelManager) shareInstance];
		  [panelManager dismissWithAnimation:YES completion:nil];
		};
		[viewModels addObject:coverViewModel];
	}

	// 音频下载功能
	if (enableSaveAudio) {
		AWELongPressPanelBaseViewModel *audioViewModel = [[%c(AWELongPressPanelBaseViewModel) alloc] init];
		audioViewModel.awemeModel = self.awemeModel;
		audioViewModel.actionType = 668;
		audioViewModel.duxIconName = @"ic_boxarrowdownhigh_outlined";
		audioViewModel.describeString = @"保存音频";
		audioViewModel.action = ^{
		  AWEAwemeModel *awemeModel = self.awemeModel;
		  AWEMusicModel *musicModel = awemeModel.music;
		  if (musicModel && musicModel.playURL && musicModel.playURL.originURLList.count > 0) {
			  NSURL *url = [NSURL URLWithString:musicModel.playURL.originURLList.firstObject];
			  [DYYYManager downloadMedia:url mediaType:MediaTypeAudio completion:nil];
		  }
		  AWELongPressPanelManager *panelManager = [%c(AWELongPressPanelManager) shareInstance];
		  [panelManager dismissWithAnimation:YES completion:nil];
		};
		[viewModels addObject:audioViewModel];
	}

	// 创建视频功能
	if (enableCreateVideo && self.awemeModel.awemeType == 68) {
		AWELongPressPanelBaseViewModel *createVideoViewModel = [[%c(AWELongPressPanelBaseViewModel) alloc] init];
		createVideoViewModel.awemeModel = self.awemeModel;
		createVideoViewModel.actionType = 677;
		createVideoViewModel.duxIconName = @"ic_videosearch_outlined_20";
		createVideoViewModel.describeString = @"制作视频";
		createVideoViewModel.action = ^{
		  AWEAwemeModel *awemeModel = self.awemeModel;

		  // 收集普通图片URL
		  NSMutableArray *imageURLs = [NSMutableArray array];
		  // 收集实况照片信息（图片URL+视频URL）
		  NSMutableArray *livePhotos = [NSMutableArray array];

		  // 获取背景音乐URL
		  NSString *bgmURL = nil;
		  if (awemeModel.music && awemeModel.music.playURL && awemeModel.music.playURL.originURLList.count > 0) {
			  bgmURL = awemeModel.music.playURL.originURLList.firstObject;
		  }

		  // 处理所有图片和实况
		  for (AWEImageAlbumImageModel *imageModel in awemeModel.albumImages) {
			  if (imageModel.urlList.count > 0) {
				  // 查找非.image后缀的URL
				  NSString *bestURL = nil;
				  for (NSString *urlString in imageModel.urlList) {
					  NSURL *url = [NSURL URLWithString:urlString];
					  NSString *pathExtension = [url.path.lowercaseString pathExtension];
					  if (![pathExtension isEqualToString:@"image"]) {
						  bestURL = urlString;
						  break;
					  }
				  }

				  if (!bestURL && imageModel.urlList.count > 0) {
					  bestURL = imageModel.urlList.firstObject;
				  }

				  // 如果是实况照片，需要收集图片和视频URL
				  if (imageModel.clipVideo != nil) {
					  NSURL *videoURL = [imageModel.clipVideo.playURL getDYYYSrcURLDownload];
					  if (videoURL) {
						  [livePhotos addObject:@{@"imageURL" : bestURL, @"videoURL" : videoURL.absoluteString}];
					  }
				  } else {
					  // 普通图片
					  [imageURLs addObject:bestURL];
				  }
			  }
		  }

		  // 调用视频创建API
		  [DYYYManager createVideoFromMedia:imageURLs
		      livePhotos:livePhotos
		      bgmURL:bgmURL
		      progress:^(NSInteger current, NSInteger total, NSString *status) {
		      }
		      completion:^(BOOL success, NSString *message) {
			if (success) {
			} else {
				[DYYYUtils showToast:[NSString stringWithFormat:@"视频制作失败: %@", message]];
			}
		      }];

		  AWELongPressPanelManager *panelManager = [%c(AWELongPressPanelManager) shareInstance];
		  [panelManager dismissWithAnimation:YES completion:nil];
		};
		[viewModels addObject:createVideoViewModel];
	}

	// 复制文案功能
	if (enableCopyText) {
		AWELongPressPanelBaseViewModel *copyText = [[%c(AWELongPressPanelBaseViewModel) alloc] init];
		copyText.awemeModel = self.awemeModel;
		copyText.actionType = 671;
		copyText.duxIconName = @"ic_xiaoxihuazhonghua_outlined";
		copyText.describeString = @"复制文案";
		copyText.action = ^{
		  NSString *descText = [self.awemeModel valueForKey:@"descriptionString"];
		  [[UIPasteboard generalPasteboard] setString:descText];
		  [DYYYToast showSuccessToastWithMessage:@"文案已复制"];
		  AWELongPressPanelManager *panelManager = [%c(AWELongPressPanelManager) shareInstance];
		  [panelManager dismissWithAnimation:YES completion:nil];
		};
		[viewModels addObject:copyText];
	}

	// 复制分享链接功能
	if (enableCopyLink) {
		AWELongPressPanelBaseViewModel *copyShareLink = [[%c(AWELongPressPanelBaseViewModel) alloc] init];
		copyShareLink.awemeModel = self.awemeModel;
		copyShareLink.actionType = 672;
		copyShareLink.duxIconName = @"ic_share_outlined";
		copyShareLink.describeString = @"复制链接";
		copyShareLink.action = ^{
		  NSString *shareLink = [self.awemeModel valueForKey:@"shareURL"];
		  NSString *cleanedURL = cleanShareURL(shareLink);
		  [[UIPasteboard generalPasteboard] setString:cleanedURL];
		  [DYYYToast showSuccessToastWithMessage:@"分享链接已复制"];
		  AWELongPressPanelManager *panelManager = [%c(AWELongPressPanelManager) shareInstance];
		  [panelManager dismissWithAnimation:YES completion:nil];
		};
		[viewModels addObject:copyShareLink];
	}

	// 过滤用户功能
	if (enableFilterUser) {
		AWELongPressPanelBaseViewModel *filterKeywords = [[%c(AWELongPressPanelBaseViewModel) alloc] init];
		filterKeywords.awemeModel = self.awemeModel;
		filterKeywords.actionType = 674;
		filterKeywords.duxIconName = @"ic_userban_outlined_20";
		filterKeywords.describeString = @"过滤用户";
		filterKeywords.action = ^{
		  AWEUserModel *author = self.awemeModel.author;
		  NSString *nickname = author.nickname ?: @"未知用户";
		  NSString *shortId = author.shortID ?: @"";
		  // 创建当前用户的过滤格式 "nickname-shortid"
		  NSString *currentUserFilter = [NSString stringWithFormat:@"%@-%@", nickname, shortId];
		  // 获取保存的过滤用户列表
		  NSString *savedUsers = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYfilterUsers"] ?: @"";
		  NSArray *userArray = [savedUsers length] > 0 ? [savedUsers componentsSeparatedByString:@","] : @[];
		  BOOL userExists = NO;
		  for (NSString *userInfo in userArray) {
			  NSArray *components = [userInfo componentsSeparatedByString:@"-"];
			  if (components.count >= 2) {
				  NSString *userId = [components lastObject];
				  if ([userId isEqualToString:shortId] && shortId.length > 0) {
					  userExists = YES;
					  break;
				  }
			  }
		  }
		  NSString *actionButtonText = userExists ? @"取消过滤" : @"添加过滤";
		  [DYYYBottomAlertView showAlertWithTitle:@"过滤用户视频"
		      message:[NSString stringWithFormat:@"用户: %@ (ID: %@)", nickname, shortId]
		      avatarURL:nil
		      cancelButtonText:@"管理过滤列表"
		      confirmButtonText:actionButtonText
		      cancelAction:^{
			DYYYKeywordListView *keywordListView = [[DYYYKeywordListView alloc] initWithTitle:@"过滤用户列表" keywords:userArray];
			keywordListView.onConfirm = ^(NSArray *users) {
			  NSString *userString = [users componentsJoinedByString:@","];
			  [[NSUserDefaults standardUserDefaults] setObject:userString forKey:@"DYYYfilterUsers"];
			  [[NSUserDefaults standardUserDefaults] synchronize];
			  [DYYYUtils showToast:@"过滤用户列表已更新"];
			};
			[keywordListView show];
		      }
		      closeAction:nil
		      confirmAction:^{
			// 添加或移除用户过滤
			NSMutableArray *updatedUsers = [NSMutableArray arrayWithArray:userArray];
			if (userExists) {
				// 移除用户
				NSMutableArray *toRemove = [NSMutableArray array];
				for (NSString *userInfo in updatedUsers) {
					NSArray *components = [userInfo componentsSeparatedByString:@"-"];
					if (components.count >= 2) {
						NSString *userId = [components lastObject];
						if ([userId isEqualToString:shortId]) {
							[toRemove addObject:userInfo];
						}
					}
				}
				[updatedUsers removeObjectsInArray:toRemove];
				[DYYYUtils showToast:@"已从过滤列表中移除此用户"];
			} else {
				// 添加用户
				[updatedUsers addObject:currentUserFilter];
				[DYYYUtils showToast:@"已添加此用户到过滤列表"];
			}
			// 保存更新后的列表
			NSString *updatedUserString = [updatedUsers componentsJoinedByString:@","];
			[[NSUserDefaults standardUserDefaults] setObject:updatedUserString forKey:@"DYYYfilterUsers"];
			[[NSUserDefaults standardUserDefaults] synchronize];
		      }];
		};
		[viewModels addObject:filterKeywords];
	}

	// 过滤文案功能
	if (enableFilterKeyword) {
		AWELongPressPanelBaseViewModel *filterKeywords = [[%c(AWELongPressPanelBaseViewModel) alloc] init];
		filterKeywords.awemeModel = self.awemeModel;
		filterKeywords.actionType = 675;
		filterKeywords.duxIconName = @"ic_funnel_outlined_20";
		filterKeywords.describeString = @"过滤文案";
		filterKeywords.action = ^{
                  NSString *descText = [self.awemeModel valueForKey:@"descriptionString"];
                  NSString *propName = nil;
                  if (self.awemeModel.propGuideV2) {
                      propName = self.awemeModel.propGuideV2.propName;
                  }
                  DYYYFilterSettingsView *filterView = [[DYYYFilterSettingsView alloc] initWithTitle:@"过滤关键词调整" text:descText propName:propName];
		  filterView.onConfirm = ^(NSString *selectedText) {
		    if (selectedText.length > 0) {
			    NSString *currentKeywords = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYfilterKeywords"] ?: @"";
			    NSString *newKeywords;
			    if (currentKeywords.length > 0) {
				    newKeywords = [NSString stringWithFormat:@"%@,%@", currentKeywords, selectedText];
			    } else {
				    newKeywords = selectedText;
			    }
			    [[NSUserDefaults standardUserDefaults] setObject:newKeywords forKey:@"DYYYfilterKeywords"];
			    [[NSUserDefaults standardUserDefaults] synchronize];
			    [DYYYUtils showToast:[NSString stringWithFormat:@"已添加过滤词: %@", selectedText]];
		    }
		  };
		  // 设置过滤关键词按钮回调
		  filterView.onKeywordFilterTap = ^{
		    // 获取保存的关键词
		    NSString *savedKeywords = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYfilterKeywords"] ?: @"";
		    NSArray *keywordArray = [savedKeywords length] > 0 ? [savedKeywords componentsSeparatedByString:@","] : @[];
		    // 创建并显示关键词列表视图
		    DYYYKeywordListView *keywordListView = [[DYYYKeywordListView alloc] initWithTitle:@"设置过滤关键词" keywords:keywordArray];
		    // 设置确认回调
		    keywordListView.onConfirm = ^(NSArray *keywords) {
		      // 将关键词数组转换为逗号分隔的字符串
		      NSString *keywordString = [keywords componentsJoinedByString:@","];
		      // 保存到用户默认设置
		      [[NSUserDefaults standardUserDefaults] setObject:keywordString forKey:@"DYYYfilterKeywords"];
		      [[NSUserDefaults standardUserDefaults] synchronize];
		      // 显示提示
		      [DYYYUtils showToast:@"过滤关键词已更新"];
		    };
		    // 显示关键词列表视图
		    [keywordListView show];
		  };
		  [filterView show];
		  AWELongPressPanelManager *panelManager = [%c(AWELongPressPanelManager) shareInstance];
		  [panelManager dismissWithAnimation:YES completion:nil];
		};
		[viewModels addObject:filterKeywords];
	}

	if (enableTimerClose) {
		AWELongPressPanelBaseViewModel *timerCloseViewModel = [[%c(AWELongPressPanelBaseViewModel) alloc] init];
		timerCloseViewModel.awemeModel = self.awemeModel;
		timerCloseViewModel.actionType = 676;
		timerCloseViewModel.duxIconName = @"ic_c_alarm_outlined";
		// 检查是否已有定时任务在运行
		NSNumber *shutdownTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYTimerShutdownTime"];
		BOOL hasActiveTimer = shutdownTime != nil && [shutdownTime doubleValue] > [[NSDate date] timeIntervalSince1970];
		timerCloseViewModel.describeString = hasActiveTimer ? @"取消定时" : @"定时关闭";
		timerCloseViewModel.action = ^{
		  AWELongPressPanelManager *panelManager = [%c(AWELongPressPanelManager) shareInstance];
		  [panelManager dismissWithAnimation:YES completion:nil];
		  NSNumber *shutdownTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYTimerShutdownTime"];
		  BOOL hasActiveTimer = shutdownTime != nil && [shutdownTime doubleValue] > [[NSDate date] timeIntervalSince1970];
		  if (hasActiveTimer) {
			  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DYYYTimerShutdownTime"];
			  [[NSUserDefaults standardUserDefaults] synchronize];
			  [DYYYUtils showToast:@"已取消定时关闭任务"];
			  return;
		  }
		  // 读取上次设置的时间
		  NSInteger defaultMinutes = [[NSUserDefaults standardUserDefaults] integerForKey:@"DYYYTimerCloseMinutes"];
		  if (defaultMinutes <= 0) {
			  defaultMinutes = 5;
		  }
		  NSString *defaultText = [NSString stringWithFormat:@"%ld", (long)defaultMinutes];
		  DYYYCustomInputView *inputView = [[DYYYCustomInputView alloc] initWithTitle:@"设置定时关闭时间" defaultText:defaultText placeholder:@"请输入关闭时间(单位:分钟)"];
		  inputView.onConfirm = ^(NSString *inputText) {
		    NSInteger minutes = [inputText integerValue];
		    if (minutes <= 0) {
			    minutes = 5;
		    }
		    // 保存用户设置的时间以供下次使用
		    [[NSUserDefaults standardUserDefaults] setInteger:minutes forKey:@"DYYYTimerCloseMinutes"];
		    [[NSUserDefaults standardUserDefaults] synchronize];
		    NSInteger seconds = minutes * 60;
		    NSTimeInterval shutdownTimeValue = [[NSDate date] timeIntervalSince1970] + seconds;
		    [[NSUserDefaults standardUserDefaults] setObject:@(shutdownTimeValue) forKey:@"DYYYTimerShutdownTime"];
		    [[NSUserDefaults standardUserDefaults] synchronize];
		    [DYYYUtils showToast:[NSString stringWithFormat:@"抖音将在%ld分钟后关闭...", (long)minutes]];
		    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		      NSNumber *currentShutdownTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYTimerShutdownTime"];
		      if (currentShutdownTime != nil && [currentShutdownTime doubleValue] <= [[NSDate date] timeIntervalSince1970]) {
			      [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DYYYTimerShutdownTime"];
			      [[NSUserDefaults standardUserDefaults] synchronize];
			      // 显示确认关闭弹窗，而不是直接退出
			      DYYYConfirmCloseView *confirmView = [[DYYYConfirmCloseView alloc] initWithTitle:@"定时关闭" message:@"定时关闭时间已到，是否关闭抖音？"];
			      [confirmView show];
		      }
		    });
		  };
		  [inputView show];
		};
		[viewModels addObject:timerCloseViewModel];
	}

	// 创建自定义组
	NSMutableArray *customGroups = [NSMutableArray array];
	NSInteger totalButtons = viewModels.count;

	// 根据按钮总数确定每行的按钮数
	NSInteger firstRowCount = 0;
	NSInteger secondRowCount = 0;

	// 确定分配方式与原代码相同
	if (totalButtons <= 2) {
		firstRowCount = totalButtons;
	} else if (totalButtons <= 4) {
		firstRowCount = totalButtons / 2;
		secondRowCount = totalButtons - firstRowCount;
	} else if (totalButtons <= 5) {
		firstRowCount = 3;
		secondRowCount = totalButtons - firstRowCount;
	} else if (totalButtons <= 6) {
		firstRowCount = 4;
		secondRowCount = totalButtons - firstRowCount;
	} else if (totalButtons <= 8) {
		firstRowCount = 4;
		secondRowCount = totalButtons - firstRowCount;
	} else {
		firstRowCount = 5;
		secondRowCount = totalButtons - firstRowCount;
	}

	// 创建第一行
	if (firstRowCount > 0) {
		NSArray<AWELongPressPanelBaseViewModel *> *firstRowButtons = [viewModels subarrayWithRange:NSMakeRange(0, firstRowCount)];
		AWELongPressPanelViewGroupModel *firstRowGroup = [[%c(AWELongPressPanelViewGroupModel) alloc] init];
		firstRowGroup.isDYYYCustomGroup = YES;
		firstRowGroup.groupType = (firstRowCount <= 3) ? 11 : 12;
		firstRowGroup.isModern = YES;
		firstRowGroup.groupArr = firstRowButtons;
		[customGroups addObject:firstRowGroup];
	}

	// 创建第二行
	if (secondRowCount > 0) {
		NSArray<AWELongPressPanelBaseViewModel *> *secondRowButtons = [viewModels subarrayWithRange:NSMakeRange(firstRowCount, secondRowCount)];
		AWELongPressPanelViewGroupModel *secondRowGroup = [[%c(AWELongPressPanelViewGroupModel) alloc] init];
		secondRowGroup.isDYYYCustomGroup = YES;
		secondRowGroup.groupType = (secondRowCount <= 3) ? 11 : 12;
		secondRowGroup.isModern = YES;
		secondRowGroup.groupArr = secondRowButtons;
		[customGroups addObject:secondRowGroup];
	}

	// 准备最终结果数组
	NSMutableArray *resultArray = [NSMutableArray arrayWithArray:customGroups];

	// 添加修改后的原始组
	[resultArray addObjectsFromArray:modifiedOriginalGroups];

	return resultArray;
}
%end

// 修复Modern风格长按面板水平设置单元格的大小计算
%hook AWEModernLongPressHorizontalSettingCell
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	if (self.longPressViewGroupModel && [self.longPressViewGroupModel isDYYYCustomGroup]) {
		if (self.dataArray && indexPath.item < self.dataArray.count) {
			CGFloat totalWidth = collectionView.bounds.size.width;
			NSInteger itemCount = self.dataArray.count;
			CGFloat itemWidth = totalWidth / itemCount;
			return CGSizeMake(itemWidth, 73);
		}
		return CGSizeMake(73, 73);
	}
	return %orig;
}
%end

// 修复Modern风格长按面板交互单元格的大小计算
%hook AWEModernLongPressInteractiveCell
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	if (self.longPressViewGroupModel && [self.longPressViewGroupModel isDYYYCustomGroup]) {
		if (self.dataArray && indexPath.item < self.dataArray.count) {
			NSInteger itemCount = self.dataArray.count;
			CGFloat totalWidth = collectionView.bounds.size.width - 12 * (itemCount - 1);
			CGFloat itemWidth = totalWidth / itemCount;
			return CGSizeMake(itemWidth, 73);
		}
		return CGSizeMake(73, 73);
	}
	return %orig;
}
%end

// 经典风格长按面板
%hook AWELongPressPanelTableViewController
- (NSArray *)dataArray {
	NSArray *originalArray = %orig;
	if (!originalArray) {
		originalArray = @[];
	}
	if (!self.awemeModel.author.nickname) {
		return originalArray;
	}

	// 检查是否启用了任意长按功能
	BOOL hasAnyFeatureEnabled = NO;

	// 检查各个单独的功能开关
	BOOL enableSaveVideo = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYLongPressSaveVideo"];
	BOOL enableSaveCover = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYLongPressSaveCover"];
	BOOL enableSaveAudio = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYLongPressSaveAudio"];
	BOOL enableSaveCurrentImage = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYLongPressSaveCurrentImage"];
	BOOL enableSaveAllImages = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYLongPressSaveAllImages"];
	BOOL enableCopyText = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYLongPressCopyText"];
	BOOL enableCopyLink = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYLongPressCopyLink"];
	BOOL enableApiDownload = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYLongPressApiDownload"];
	BOOL enableFilterUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYLongPressFilterUser"];
	BOOL enableFilterKeyword = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYLongPressFilterTitle"];
	BOOL enableTimerClose = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYLongPressTimerClose"];
	BOOL enableCreateVideo = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYLongPressCreateVideo"];

	// 检查是否有任何功能启用
	hasAnyFeatureEnabled = enableSaveVideo || enableSaveCover || enableSaveAudio || enableSaveCurrentImage || enableSaveAllImages || enableCopyText || enableCopyLink || enableApiDownload ||
			       enableFilterUser || enableFilterKeyword || enableTimerClose || enableCreateVideo;

	// 处理原始面板按钮的显示/隐藏
	NSMutableArray *modifiedArray = [NSMutableArray array];

	// 获取需要隐藏的按钮设置
	BOOL hideDaily = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelDaily"];
	BOOL hideRecommend = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelRecommend"];
	BOOL hideNotInterested = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelNotInterested"];
	BOOL hideReport = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelReport"];
	BOOL hideSpeed = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelSpeed"];
	BOOL hideClearScreen = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelClearScreen"];
	BOOL hideFavorite = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelFavorite"];
	BOOL hideLater = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelLater"];
	BOOL hideCast = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelCast"];
	BOOL hideOpenInPC = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelOpenInPC"];
	BOOL hideSubtitle = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelSubtitle"];
	BOOL hideAutoPlay = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelAutoPlay"];
	BOOL hideSearchImage = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelSearchImage"];
	BOOL hideListenDouyin = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelListenDouyin"];
	BOOL hideBackgroundPlay = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelBackgroundPlay"];
	BOOL hideBiserial = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelBiserial"];
	BOOL hideTimerclose = [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHidePanelTimerClose"];

	// 处理原始面板
	for (id group in originalArray) {
		// 检查是否为视图组模型
		if ([group isKindOfClass:%c(AWELongPressPanelViewGroupModel)]) {
			AWELongPressPanelViewGroupModel *groupModel = (AWELongPressPanelViewGroupModel *)group;
			NSMutableArray *filteredGroupArr = [NSMutableArray array];
			for (id item in groupModel.groupArr) {
				// 检查是否为基础视图模型
				if ([item isKindOfClass:%c(AWELongPressPanelBaseViewModel)]) {
					AWELongPressPanelBaseViewModel *viewModel = (AWELongPressPanelBaseViewModel *)item;
					NSString *descString = viewModel.describeString;
					// 根据描述字符串判断按钮类型并决定是否隐藏
					BOOL shouldHide = NO;
					if ([descString isEqualToString:@"转发到日常"] && hideDaily) {
						shouldHide = YES;
					} else if (([descString isEqualToString:@"推荐"] || [descString isEqualToString:@"取消推荐"]) && hideRecommend) {
						shouldHide = YES;
					} else if ([descString isEqualToString:@"不感兴趣"] && hideNotInterested) {
						shouldHide = YES;
					} else if ([descString isEqualToString:@"举报"] && hideReport) {
						shouldHide = YES;
					} else if ([descString isEqualToString:@"倍速"] && hideSpeed) {
						shouldHide = YES;
					} else if ([descString isEqualToString:@"清屏播放"] && hideClearScreen) {
						shouldHide = YES;
					} else if ([descString isEqualToString:@"缓存视频"] && hideFavorite) {
						shouldHide = YES;
					} else if ([descString isEqualToString:@"添加至稍后再看"] && hideLater) {
						shouldHide = YES;
					} else if ([descString isEqualToString:@"投屏"] && hideCast) {
						shouldHide = YES;
					} else if ([descString isEqualToString:@"电脑/Pad打开"] && hideOpenInPC) {
						shouldHide = YES;
					} else if ([descString isEqualToString:@"弹幕"] && hideSubtitle) {
						shouldHide = YES;
					} else if ([descString isEqualToString:@"弹幕开关"] && hideSubtitle) {
						shouldHide = YES;
					} else if ([descString isEqualToString:@"弹幕设置"] && hideSubtitle) {
						shouldHide = YES;
					} else if ([descString isEqualToString:@"自动连播"] && hideAutoPlay) {
						shouldHide = YES;
					} else if ([descString isEqualToString:@"识别图片"] && hideSearchImage) {
						shouldHide = YES;
					} else if (([descString isEqualToString:@"听抖音"] || [descString isEqualToString:@"后台听"] || [descString isEqualToString:@"听视频"]) && hideListenDouyin) {
						shouldHide = YES;
					} else if ([descString isEqualToString:@"后台播放设置"] && hideBackgroundPlay) {
						shouldHide = YES;
					} else if ([descString isEqualToString:@"首页双列快捷入口"] && hideBiserial) {
						shouldHide = YES;
					} else if ([descString isEqualToString:@"定时关闭"] && hideTimerclose) {
						shouldHide = YES;
					}

					if (!shouldHide) {
						[filteredGroupArr addObject:viewModel];
					}
				} else {
					// 不是视图模型的，直接添加
					[filteredGroupArr addObject:item];
				}
			}
			// 如果过滤后的数组不为空，则保留原始结构
			if (filteredGroupArr.count > 0) {
				AWELongPressPanelViewGroupModel *newGroup = [[%c(AWELongPressPanelViewGroupModel) alloc] init];
				newGroup.groupType = groupModel.groupType;
				newGroup.groupArr = filteredGroupArr;
				[modifiedArray addObject:newGroup];
			}
		} else {
			// 不是组模型的，直接添加
			[modifiedArray addObject:group];
		}
	}

	if (!hasAnyFeatureEnabled) {
		return modifiedArray;
	}

	// 创建自定义功能组
	AWELongPressPanelViewGroupModel *newGroupModel = [[%c(AWELongPressPanelViewGroupModel) alloc] init];
	newGroupModel.groupType = 0;
	NSMutableArray *viewModels = [NSMutableArray array];

	BOOL isNewLivePhoto = (self.awemeModel.video && self.awemeModel.animatedImageVideoInfo != nil);

	// 视频下载功能 (非实况照片才显示)
	if (enableSaveVideo && self.awemeModel.awemeType != 68 && !isNewLivePhoto) {
		AWELongPressPanelBaseViewModel *downloadViewModel = [[%c(AWELongPressPanelBaseViewModel) alloc] init];
		downloadViewModel.awemeModel = self.awemeModel;
		downloadViewModel.actionType = 666;
		downloadViewModel.duxIconName = @"ic_boxarrowdownhigh_outlined";
		downloadViewModel.describeString = @"保存视频";
		downloadViewModel.action = ^{
		  AWEAwemeModel *awemeModel = self.awemeModel;
		  AWEVideoModel *videoModel = awemeModel.video;

		  if (videoModel && videoModel.bitrateModels && videoModel.bitrateModels.count > 0) {
			  // 优先使用bitrateModels中的最高质量版本
			  id highestQualityModel = videoModel.bitrateModels.firstObject;
			  NSArray *urlList = nil;
			  id playAddrObj = [highestQualityModel valueForKey:@"playAddr"];

			  if ([playAddrObj isKindOfClass:%c(AWEURLModel)]) {
				  AWEURLModel *playAddrModel = (AWEURLModel *)playAddrObj;
				  urlList = playAddrModel.originURLList;
			  }

			  if (urlList && urlList.count > 0) {
				  NSURL *url = [NSURL URLWithString:urlList.firstObject];
				  [DYYYManager downloadMedia:url
						   mediaType:MediaTypeVideo
						  completion:^(BOOL success){
						  }];
			  } else {
				  // 备用方法：直接使用h264URL
				  if (videoModel.h264URL && videoModel.h264URL.originURLList.count > 0) {
					  NSURL *url = [NSURL URLWithString:videoModel.h264URL.originURLList.firstObject];
					  [DYYYManager downloadMedia:url
							   mediaType:MediaTypeVideo
							  completion:^(BOOL success){
							  }];
				  }
			  }
		  }
		  AWELongPressPanelManager *panelManager = [%c(AWELongPressPanelManager) shareInstance];
		  [panelManager dismissWithAnimation:YES completion:nil];
		};
		[viewModels addObject:downloadViewModel];
	}

	//  新版实况照片保存
	if (enableSaveVideo && self.awemeModel.awemeType != 68 && isNewLivePhoto) {
		AWELongPressPanelBaseViewModel *livePhotoViewModel = [[%c(AWELongPressPanelBaseViewModel) alloc] init];
		livePhotoViewModel.awemeModel = self.awemeModel;
		livePhotoViewModel.actionType = 679;
		livePhotoViewModel.duxIconName = @"ic_boxarrowdownhigh_outlined";
		livePhotoViewModel.describeString = @"保存实况";
		livePhotoViewModel.action = ^{
		  AWEAwemeModel *awemeModel = self.awemeModel;
		  AWEVideoModel *videoModel = awemeModel.video;

		  // 使用封面URL作为图片URL
		  NSURL *imageURL = nil;
		  if (videoModel.coverURL && videoModel.coverURL.originURLList.count > 0) {
			  imageURL = [NSURL URLWithString:videoModel.coverURL.originURLList.firstObject];
		  }

		  // 视频URL从视频模型获取
		  NSURL *videoURL = nil;
		  if (videoModel && videoModel.playURL && videoModel.playURL.originURLList.count > 0) {
			  videoURL = [NSURL URLWithString:videoModel.playURL.originURLList.firstObject];
		  } else if (videoModel && videoModel.h264URL && videoModel.h264URL.originURLList.count > 0) {
			  videoURL = [NSURL URLWithString:videoModel.h264URL.originURLList.firstObject];
		  }

		  // 下载实况照片
		  if (imageURL && videoURL) {
			  [DYYYManager downloadLivePhoto:imageURL
						videoURL:videoURL
					      completion:^{
					      }];
		  }

		  AWELongPressPanelManager *panelManager = [%c(AWELongPressPanelManager) shareInstance];
		  [panelManager dismissWithAnimation:YES completion:nil];
		};
		[viewModels addObject:livePhotoViewModel];
	}

	// 当前图片/实况下载功能
	if (enableSaveCurrentImage && self.awemeModel.awemeType == 68 && self.awemeModel.albumImages.count > 0) {
		AWELongPressPanelBaseViewModel *imageViewModel = [[%c(AWELongPressPanelBaseViewModel) alloc] init];
		imageViewModel.awemeModel = self.awemeModel;
		imageViewModel.actionType = 669;
		imageViewModel.duxIconName = @"ic_boxarrowdownhigh_outlined";

		if (self.awemeModel.albumImages.count == 1) {
			imageViewModel.describeString = @"保存图片";
		} else {
			imageViewModel.describeString = @"保存当前图片";
		}

		AWEImageAlbumImageModel *currimge = self.awemeModel.albumImages[self.awemeModel.currentImageIndex - 1];
		if (currimge.clipVideo != nil || self.awemeModel.isLivePhoto) {
			if (self.awemeModel.albumImages.count == 1) {
				imageViewModel.describeString = @"保存实况";
			} else {
				imageViewModel.describeString = @"保存当前实况";
			}
		}

		imageViewModel.action = ^{
		  AWEAwemeModel *awemeModel = self.awemeModel;
		  AWEImageAlbumImageModel *currentImageModel = nil;
		  if (awemeModel.currentImageIndex > 0 && awemeModel.currentImageIndex <= awemeModel.albumImages.count) {
			  currentImageModel = awemeModel.albumImages[awemeModel.currentImageIndex - 1];
		  } else {
			  currentImageModel = awemeModel.albumImages.firstObject;
		  }
		  // 如果是实况的话
		  // 查找非.image后缀的URL
		  NSURL *downloadURL = nil;
		  for (NSString *urlString in currentImageModel.urlList) {
			  NSURL *url = [NSURL URLWithString:urlString];
			  NSString *pathExtension = [url.path.lowercaseString pathExtension];
			  if (![pathExtension isEqualToString:@"image"]) {
				  downloadURL = url;
				  break;
			  }
		  }

		  if (currentImageModel.clipVideo != nil) {
			  NSURL *videoURL = [currentImageModel.clipVideo.playURL getDYYYSrcURLDownload];
			  [DYYYManager downloadLivePhoto:downloadURL
						videoURL:videoURL
					      completion:^{
					      }];
		  } else if (currentImageModel && currentImageModel.urlList.count > 0) {
			  if (downloadURL) {
				  [DYYYManager downloadMedia:downloadURL
						   mediaType:MediaTypeImage
						  completion:^(BOOL success) {
						    if (success) {
						    } else {
							    [DYYYUtils showToast:@"图片保存已取消"];
						    }
						  }];
			  } else {
				  [DYYYUtils showToast:@"没有找到合适格式的图片"];
			  }
		  }
		  AWELongPressPanelManager *panelManager = [%c(AWELongPressPanelManager) shareInstance];
		  [panelManager dismissWithAnimation:YES completion:nil];
		};
		[viewModels addObject:imageViewModel];
	}

	// 保存所有图片/实况功能
	if (enableSaveAllImages && self.awemeModel.awemeType == 68 && self.awemeModel.albumImages.count > 1) {
		AWELongPressPanelBaseViewModel *allImagesViewModel = [[%c(AWELongPressPanelBaseViewModel) alloc] init];
		allImagesViewModel.awemeModel = self.awemeModel;
		allImagesViewModel.actionType = 670;
		allImagesViewModel.duxIconName = @"ic_boxarrowdownhigh_outlined";
		allImagesViewModel.describeString = @"保存所有图片";
		// 检查是否有实况照片并更改按钮文字
		BOOL hasLivePhoto = NO;
		for (AWEImageAlbumImageModel *imageModel in self.awemeModel.albumImages) {
			if (imageModel.clipVideo != nil) {
				hasLivePhoto = YES;
				break;
			}
		}
		if (hasLivePhoto) {
			allImagesViewModel.describeString = @"保存所有实况";
		}
		allImagesViewModel.action = ^{
		  AWEAwemeModel *awemeModel = self.awemeModel;
		  NSMutableArray *imageURLs = [NSMutableArray array];
		  NSMutableArray *livePhotos = [NSMutableArray array];

		  for (AWEImageAlbumImageModel *imageModel in awemeModel.albumImages) {
			  if (imageModel.urlList.count > 0) {
				  // 查找非.image后缀的URL
				  NSURL *downloadURL = nil;
				  for (NSString *urlString in imageModel.urlList) {
					  NSURL *url = [NSURL URLWithString:urlString];
					  NSString *pathExtension = [url.path.lowercaseString pathExtension];
					  if (![pathExtension isEqualToString:@"image"]) {
						  downloadURL = url;
						  break;
					  }
				  }

				  if (!downloadURL && imageModel.urlList.count > 0) {
					  downloadURL = [NSURL URLWithString:imageModel.urlList.firstObject];
				  }

				  // 检查是否是实况照片
				  if (imageModel.clipVideo != nil) {
					  NSURL *videoURL = [imageModel.clipVideo.playURL getDYYYSrcURLDownload];
					  [livePhotos addObject:@{@"imageURL" : downloadURL.absoluteString, @"videoURL" : videoURL.absoluteString}];
				  } else {
					  [imageURLs addObject:downloadURL.absoluteString];
				  }
			  }
		  }

		  // 分别处理普通图片和实况照片
		  if (livePhotos.count > 0) {
			  [DYYYManager downloadAllLivePhotos:livePhotos];
		  }

		  if (imageURLs.count > 0) {
			  [DYYYManager downloadAllImages:imageURLs];
		  }

		  if (livePhotos.count == 0 && imageURLs.count == 0) {
			  [DYYYUtils showToast:@"没有找到合适格式的图片"];
		  }

		  AWELongPressPanelManager *panelManager = [%c(AWELongPressPanelManager) shareInstance];
		  [panelManager dismissWithAnimation:YES completion:nil];
		};
		[viewModels addObject:allImagesViewModel];
	}

	// 接口保存功能
	NSString *apiKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYInterfaceDownload"];
	if (enableApiDownload && apiKey.length > 0) {
		AWELongPressPanelBaseViewModel *apiDownload = [[%c(AWELongPressPanelBaseViewModel) alloc] init];
		apiDownload.awemeModel = self.awemeModel;
		apiDownload.actionType = 673;
		apiDownload.duxIconName = @"ic_cloudarrowdown_outlined_20";
		apiDownload.describeString = @"接口保存";
		apiDownload.action = ^{
		  NSString *shareLink = [self.awemeModel valueForKey:@"shareURL"];
		  if (shareLink.length == 0) {
			  [DYYYUtils showToast:@"无法获取分享链接"];
			  return;
		  }
		  // 使用封装的方法进行解析下载
		  [DYYYManager parseAndDownloadVideoWithShareLink:shareLink apiKey:apiKey];
		  AWELongPressPanelManager *panelManager = [%c(AWELongPressPanelManager) shareInstance];
		  [panelManager dismissWithAnimation:YES completion:nil];
		};
		[viewModels addObject:apiDownload];
	}

	// 封面下载功能
	if (enableSaveCover && self.awemeModel.awemeType != 68) {
		AWELongPressPanelBaseViewModel *coverViewModel = [[%c(AWELongPressPanelBaseViewModel) alloc] init];
		coverViewModel.awemeModel = self.awemeModel;
		coverViewModel.actionType = 667;
		coverViewModel.duxIconName = @"ic_boxarrowdownhigh_outlined";
		coverViewModel.describeString = @"保存封面";
		coverViewModel.action = ^{
		  AWEAwemeModel *awemeModel = self.awemeModel;
		  AWEVideoModel *videoModel = awemeModel.video;
		  if (videoModel && videoModel.coverURL && videoModel.coverURL.originURLList.count > 0) {
			  NSURL *url = [NSURL URLWithString:videoModel.coverURL.originURLList.firstObject];
			  [DYYYManager downloadMedia:url
					   mediaType:MediaTypeImage
					  completion:^(BOOL success) {
					    if (success) {
					    } else {
						    [DYYYUtils showToast:@"封面保存已取消"];
					    }
					  }];
		  }
		  AWELongPressPanelManager *panelManager = [%c(AWELongPressPanelManager) shareInstance];
		  [panelManager dismissWithAnimation:YES completion:nil];
		};
		[viewModels addObject:coverViewModel];
	}

	// 音频下载功能
	if (enableSaveAudio) {
		AWELongPressPanelBaseViewModel *audioViewModel = [[%c(AWELongPressPanelBaseViewModel) alloc] init];
		audioViewModel.awemeModel = self.awemeModel;
		audioViewModel.actionType = 668;
		audioViewModel.duxIconName = @"ic_boxarrowdownhigh_outlined";
		audioViewModel.describeString = @"保存音频";
		audioViewModel.action = ^{
		  AWEAwemeModel *awemeModel = self.awemeModel;
		  AWEMusicModel *musicModel = awemeModel.music;
		  if (musicModel && musicModel.playURL && musicModel.playURL.originURLList.count > 0) {
			  NSURL *url = [NSURL URLWithString:musicModel.playURL.originURLList.firstObject];
			  [DYYYManager downloadMedia:url mediaType:MediaTypeAudio completion:nil];
		  }
		  AWELongPressPanelManager *panelManager = [%c(AWELongPressPanelManager) shareInstance];
		  [panelManager dismissWithAnimation:YES completion:nil];
		};
		[viewModels addObject:audioViewModel];
	}

	// 创建视频功能
	if (enableCreateVideo && self.awemeModel.awemeType == 68) {
		AWELongPressPanelBaseViewModel *createVideoViewModel = [[%c(AWELongPressPanelBaseViewModel) alloc] init];
		createVideoViewModel.awemeModel = self.awemeModel;
		createVideoViewModel.actionType = 677;
		createVideoViewModel.duxIconName = @"ic_videosearch_outlined_20";
		createVideoViewModel.describeString = @"制作视频";
		createVideoViewModel.action = ^{
		  AWEAwemeModel *awemeModel = self.awemeModel;

		  // 收集普通图片URL
		  NSMutableArray *imageURLs = [NSMutableArray array];
		  // 收集实况照片信息（图片URL+视频URL）
		  NSMutableArray *livePhotos = [NSMutableArray array];

		  // 获取背景音乐URL
		  NSString *bgmURL = nil;
		  if (awemeModel.music && awemeModel.music.playURL && awemeModel.music.playURL.originURLList.count > 0) {
			  bgmURL = awemeModel.music.playURL.originURLList.firstObject;
		  }

		  // 处理所有图片和实况
		  for (AWEImageAlbumImageModel *imageModel in awemeModel.albumImages) {
			  if (imageModel.urlList.count > 0) {
				  // 查找非.image后缀的URL
				  NSString *bestURL = nil;
				  for (NSString *urlString in imageModel.urlList) {
					  NSURL *url = [NSURL URLWithString:urlString];
					  NSString *pathExtension = [url.path.lowercaseString pathExtension];
					  if (![pathExtension isEqualToString:@"image"]) {
						  bestURL = urlString;
						  break;
					  }
				  }

				  if (!bestURL && imageModel.urlList.count > 0) {
					  bestURL = imageModel.urlList.firstObject;
				  }

				  // 如果是实况照片，需要收集图片和视频URL
				  if (imageModel.clipVideo != nil) {
					  NSURL *videoURL = [imageModel.clipVideo.playURL getDYYYSrcURLDownload];
					  if (videoURL) {
						  [livePhotos addObject:@{@"imageURL" : bestURL, @"videoURL" : videoURL.absoluteString}];
					  }
				  } else {
					  // 普通图片
					  [imageURLs addObject:bestURL];
				  }
			  }
		  }

		  // 调用视频创建API
		  [DYYYManager createVideoFromMedia:imageURLs
		      livePhotos:livePhotos
		      bgmURL:bgmURL
		      progress:^(NSInteger current, NSInteger total, NSString *status) {
		      }
		      completion:^(BOOL success, NSString *message) {
			if (success) {
			} else {
				[DYYYUtils showToast:[NSString stringWithFormat:@"视频制作失败: %@", message]];
			}
		      }];

		  AWELongPressPanelManager *panelManager = [%c(AWELongPressPanelManager) shareInstance];
		  [panelManager dismissWithAnimation:YES completion:nil];
		};
		[viewModels addObject:createVideoViewModel];
	}

	// 复制文案功能
	if (enableCopyText) {
		AWELongPressPanelBaseViewModel *copyText = [[%c(AWELongPressPanelBaseViewModel) alloc] init];
		copyText.awemeModel = self.awemeModel;
		copyText.actionType = 671;
		copyText.duxIconName = @"ic_xiaoxihuazhonghua_outlined";
		copyText.describeString = @"复制文案";
		copyText.action = ^{
		  NSString *descText = [self.awemeModel valueForKey:@"descriptionString"];
		  [[UIPasteboard generalPasteboard] setString:descText];
		  [DYYYToast showSuccessToastWithMessage:@"文案已复制"];
		  AWELongPressPanelManager *panelManager = [%c(AWELongPressPanelManager) shareInstance];
		  [panelManager dismissWithAnimation:YES completion:nil];
		};
		[viewModels addObject:copyText];
	}

	// 复制分享链接功能
	if (enableCopyLink) {
		AWELongPressPanelBaseViewModel *copyShareLink = [[%c(AWELongPressPanelBaseViewModel) alloc] init];
		copyShareLink.awemeModel = self.awemeModel;
		copyShareLink.actionType = 672;
		copyShareLink.duxIconName = @"ic_share_outlined";
		copyShareLink.describeString = @"复制链接";
		copyShareLink.action = ^{
		  NSString *shareLink = [self.awemeModel valueForKey:@"shareURL"];
		  NSString *cleanedURL = cleanShareURL(shareLink);
		  [[UIPasteboard generalPasteboard] setString:cleanedURL];
		  [DYYYToast showSuccessToastWithMessage:@"分享链接已复制"];
		  AWELongPressPanelManager *panelManager = [%c(AWELongPressPanelManager) shareInstance];
		  [panelManager dismissWithAnimation:YES completion:nil];
		};
		[viewModels addObject:copyShareLink];
	}

	// 过滤用户功能
	if (enableFilterUser) {
		AWELongPressPanelBaseViewModel *filterKeywords = [[%c(AWELongPressPanelBaseViewModel) alloc] init];
		filterKeywords.awemeModel = self.awemeModel;
		filterKeywords.actionType = 674;
		filterKeywords.duxIconName = @"ic_userban_outlined_20";
		filterKeywords.describeString = @"过滤用户";
		filterKeywords.action = ^{
		  AWEUserModel *author = self.awemeModel.author;
		  NSString *nickname = author.nickname ?: @"未知用户";
		  NSString *shortId = author.shortID ?: @"";
		  // 创建当前用户的过滤格式 "nickname-shortid"
		  NSString *currentUserFilter = [NSString stringWithFormat:@"%@-%@", nickname, shortId];
		  // 获取保存的过滤用户列表
		  NSString *savedUsers = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYfilterUsers"] ?: @"";
		  NSArray *userArray = [savedUsers length] > 0 ? [savedUsers componentsSeparatedByString:@","] : @[];
		  BOOL userExists = NO;
		  for (NSString *userInfo in userArray) {
			  NSArray *components = [userInfo componentsSeparatedByString:@"-"];
			  if (components.count >= 2) {
				  NSString *userId = [components lastObject];
				  if ([userId isEqualToString:shortId] && shortId.length > 0) {
					  userExists = YES;
					  break;
				  }
			  }
		  }
		  NSString *actionButtonText = userExists ? @"取消过滤" : @"添加过滤";
		  [DYYYBottomAlertView showAlertWithTitle:@"过滤用户视频"
		      message:[NSString stringWithFormat:@"用户: %@ (ID: %@)", nickname, shortId]
		      avatarURL:nil
		      cancelButtonText:@"管理过滤列表"
		      confirmButtonText:actionButtonText
		      cancelAction:^{
			DYYYKeywordListView *keywordListView = [[DYYYKeywordListView alloc] initWithTitle:@"过滤用户列表" keywords:userArray];
			keywordListView.onConfirm = ^(NSArray *users) {
			  NSString *userString = [users componentsJoinedByString:@","];
			  [[NSUserDefaults standardUserDefaults] setObject:userString forKey:@"DYYYfilterUsers"];
			  [[NSUserDefaults standardUserDefaults] synchronize];
			  [DYYYUtils showToast:@"过滤用户列表已更新"];
			};
			[keywordListView show];
		      }
		      closeAction:nil
		      confirmAction:^{
			// 添加或移除用户过滤
			NSMutableArray *updatedUsers = [NSMutableArray arrayWithArray:userArray];
			if (userExists) {
				// 移除用户
				NSMutableArray *toRemove = [NSMutableArray array];
				for (NSString *userInfo in updatedUsers) {
					NSArray *components = [userInfo componentsSeparatedByString:@"-"];
					if (components.count >= 2) {
						NSString *userId = [components lastObject];
						if ([userId isEqualToString:shortId]) {
							[toRemove addObject:userInfo];
						}
					}
				}
				[updatedUsers removeObjectsInArray:toRemove];
				[DYYYUtils showToast:@"已从过滤列表中移除此用户"];
			} else {
				// 添加用户
				[updatedUsers addObject:currentUserFilter];
				[DYYYUtils showToast:@"已添加此用户到过滤列表"];
			}
			// 保存更新后的列表
			NSString *updatedUserString = [updatedUsers componentsJoinedByString:@","];
			[[NSUserDefaults standardUserDefaults] setObject:updatedUserString forKey:@"DYYYfilterUsers"];
			[[NSUserDefaults standardUserDefaults] synchronize];
		      }];
		};
		[viewModels addObject:filterKeywords];
	}

	// 过滤文案功能
	if (enableFilterKeyword) {
		AWELongPressPanelBaseViewModel *filterKeywords = [[%c(AWELongPressPanelBaseViewModel) alloc] init];
		filterKeywords.awemeModel = self.awemeModel;
		filterKeywords.actionType = 675;
		filterKeywords.duxIconName = @"ic_funnel_outlined_20";
		filterKeywords.describeString = @"过滤文案";
		filterKeywords.action = ^{
                  NSString *descText = [self.awemeModel valueForKey:@"descriptionString"];
                  NSString *propName = nil;
                  if (self.awemeModel.propGuideV2) {
                      propName = self.awemeModel.propGuideV2.propName;
                  }
                  DYYYFilterSettingsView *filterView = [[DYYYFilterSettingsView alloc] initWithTitle:@"过滤关键词调整" text:descText propName:propName];
		  filterView.onConfirm = ^(NSString *selectedText) {
		    if (selectedText.length > 0) {
			    NSString *currentKeywords = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYfilterKeywords"] ?: @"";
			    NSString *newKeywords;
			    if (currentKeywords.length > 0) {
				    newKeywords = [NSString stringWithFormat:@"%@,%@", currentKeywords, selectedText];
			    } else {
				    newKeywords = selectedText;
			    }
			    [[NSUserDefaults standardUserDefaults] setObject:newKeywords forKey:@"DYYYfilterKeywords"];
			    [[NSUserDefaults standardUserDefaults] synchronize];
			    [DYYYUtils showToast:[NSString stringWithFormat:@"已添加过滤词: %@", selectedText]];
		    }
		  };
		  // 设置过滤关键词按钮回调
		  filterView.onKeywordFilterTap = ^{
		    // 获取保存的关键词
		    NSString *savedKeywords = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYfilterKeywords"] ?: @"";
		    NSArray *keywordArray = [savedKeywords length] > 0 ? [savedKeywords componentsSeparatedByString:@","] : @[];
		    // 创建并显示关键词列表视图
		    DYYYKeywordListView *keywordListView = [[DYYYKeywordListView alloc] initWithTitle:@"设置过滤关键词" keywords:keywordArray];
		    // 设置确认回调
		    keywordListView.onConfirm = ^(NSArray *keywords) {
		      // 将关键词数组转换为逗号分隔的字符串
		      NSString *keywordString = [keywords componentsJoinedByString:@","];
		      // 保存到用户默认设置
		      [[NSUserDefaults standardUserDefaults] setObject:keywordString forKey:@"DYYYfilterKeywords"];
		      [[NSUserDefaults standardUserDefaults] synchronize];
		      // 显示提示
		      [DYYYUtils showToast:@"过滤关键词已更新"];
		    };
		    // 显示关键词列表视图
		    [keywordListView show];
		  };
		  [filterView show];
		  AWELongPressPanelManager *panelManager = [%c(AWELongPressPanelManager) shareInstance];
		  [panelManager dismissWithAnimation:YES completion:nil];
		};
		[viewModels addObject:filterKeywords];
	}

	if (enableTimerClose) {
		AWELongPressPanelBaseViewModel *timerCloseViewModel = [[%c(AWELongPressPanelBaseViewModel) alloc] init];
		timerCloseViewModel.awemeModel = self.awemeModel;
		timerCloseViewModel.actionType = 676;
		timerCloseViewModel.duxIconName = @"ic_c_alarm_outlined";
		// 检查是否已有定时任务在运行
		NSNumber *shutdownTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYTimerShutdownTime"];
		BOOL hasActiveTimer = shutdownTime != nil && [shutdownTime doubleValue] > [[NSDate date] timeIntervalSince1970];
		timerCloseViewModel.describeString = hasActiveTimer ? @"取消定时" : @"定时关闭";
		timerCloseViewModel.action = ^{
		  AWELongPressPanelManager *panelManager = [%c(AWELongPressPanelManager) shareInstance];
		  [panelManager dismissWithAnimation:YES completion:nil];
		  NSNumber *shutdownTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYTimerShutdownTime"];
		  BOOL hasActiveTimer = shutdownTime != nil && [shutdownTime doubleValue] > [[NSDate date] timeIntervalSince1970];
		  if (hasActiveTimer) {
			  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DYYYTimerShutdownTime"];
			  [[NSUserDefaults standardUserDefaults] synchronize];
			  [DYYYUtils showToast:@"已取消定时关闭任务"];
			  return;
		  }
		  // 读取上次设置的时间
		  NSInteger defaultMinutes = [[NSUserDefaults standardUserDefaults] integerForKey:@"DYYYTimerCloseMinutes"];
		  if (defaultMinutes <= 0) {
			  defaultMinutes = 5;
		  }
		  NSString *defaultText = [NSString stringWithFormat:@"%ld", (long)defaultMinutes];
		  DYYYCustomInputView *inputView = [[DYYYCustomInputView alloc] initWithTitle:@"设置定时关闭时间" defaultText:defaultText placeholder:@"请输入关闭时间(单位:分钟)"];
		  inputView.onConfirm = ^(NSString *inputText) {
		    NSInteger minutes = [inputText integerValue];
		    if (minutes <= 0) {
			    minutes = 5;
		    }
		    // 保存用户设置的时间以供下次使用
		    [[NSUserDefaults standardUserDefaults] setInteger:minutes forKey:@"DYYYTimerCloseMinutes"];
		    [[NSUserDefaults standardUserDefaults] synchronize];
		    NSInteger seconds = minutes * 60;
		    NSTimeInterval shutdownTimeValue = [[NSDate date] timeIntervalSince1970] + seconds;
		    [[NSUserDefaults standardUserDefaults] setObject:@(shutdownTimeValue) forKey:@"DYYYTimerShutdownTime"];
		    [[NSUserDefaults standardUserDefaults] synchronize];
		    [DYYYUtils showToast:[NSString stringWithFormat:@"抖音将在%ld分钟后关闭...", (long)minutes]];
		    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		      NSNumber *currentShutdownTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"DYYYTimerShutdownTime"];
		      if (currentShutdownTime != nil && [currentShutdownTime doubleValue] <= [[NSDate date] timeIntervalSince1970]) {
			      [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DYYYTimerShutdownTime"];
			      [[NSUserDefaults standardUserDefaults] synchronize];
			      // 显示确认关闭弹窗，而不是直接退出
			      DYYYConfirmCloseView *confirmView = [[DYYYConfirmCloseView alloc] initWithTitle:@"定时关闭" message:@"定时关闭时间已到，是否关闭抖音？"];
			      [confirmView show];
		      }
		    });
		  };
		  [inputView show];
		};
		[viewModels addObject:timerCloseViewModel];
	}

	newGroupModel.groupArr = viewModels;

	// 返回自定义组+原始组的结果
	if (modifiedArray.count > 0) {
		NSMutableArray *resultArray = [modifiedArray mutableCopy];
		[resultArray insertObject:newGroupModel atIndex:0];
		return [resultArray copy];
	} else {
		return @[ newGroupModel ];
	}
}
%end

// 隐藏评论分享功能

%hook AWEIMCommentShareUserHorizontalCollectionViewCell

- (void)layoutSubviews {
	%orig;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCommentShareToFriends"]) {
		self.hidden = YES;
	} else {
		self.hidden = NO;
	}
}

%end

%hook AWEIMCommentShareUserHorizontalSectionController

- (CGSize)sizeForItemAtIndex:(NSInteger)index model:(id)model collectionViewSize:(CGSize)size {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCommentShareToFriends"]) {
		return CGSizeZero;
	}
	return %orig;
}

- (void)configCell:(id)cell index:(NSInteger)index model:(id)model {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCommentShareToFriends"]) {
		return;
	}
	%orig;
}

%end

%ctor {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYUserAgreementAccepted"]) {
		%init;
	}
}

%group DYYYFilterSetterGroup

%hook HOOK_TARGET_OWNER_CLASS

- (void)setModelsArray:(id)arg1 {
	if (![arg1 isKindOfClass:[NSArray class]]) {
		%orig(arg1);
		return;
	}

	NSArray *inputArray = (NSArray *)arg1;
	NSMutableArray *filteredArray = nil;

	for (id item in inputArray) {
		NSString *className = NSStringFromClass([item class]);

		BOOL shouldFilter = ([className isEqualToString:@"AWECommentIMSwiftImpl.CommentLongPressPanelForwardElement"] &&
				     [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCommentLongPressDaily"]) ||

				    ([className isEqualToString:@"AWECommentLongPressPanelSwiftImpl.CommentLongPressPanelCopyElement"] &&
				     [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCommentLongPressCopy"]) ||

				    ([className isEqualToString:@"AWECommentLongPressPanelSwiftImpl.CommentLongPressPanelSaveImageElement"] &&
				     [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCommentLongPressSaveImage"]) ||

				    ([className isEqualToString:@"AWECommentLongPressPanelSwiftImpl.CommentLongPressPanelReportElement"] &&
				     [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCommentLongPressReport"]) ||

				    ([className isEqualToString:@"AWECommentStudioSwiftImpl.CommentLongPressPanelVideoReplyElement"] &&
				     [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCommentLongPressVideoReply"]) ||

				    ([className isEqualToString:@"AWECommentSearchSwiftImpl.CommentLongPressPanelPictureSearchElement"] &&
				     [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCommentLongPressPictureSearch"]) ||

				    ([className isEqualToString:@"AWECommentSearchSwiftImpl.CommentLongPressPanelSearchElement"] &&
				     [[NSUserDefaults standardUserDefaults] boolForKey:@"DYYYHideCommentLongPressSearch"]);

		if (shouldFilter) {
			if (!filteredArray) {
				filteredArray = [NSMutableArray arrayWithCapacity:inputArray.count];
				for (id keepItem in inputArray) {
					if (keepItem == item)
						break;
					[filteredArray addObject:keepItem];
				}
			}
			continue;
		}

		if (filteredArray) {
			[filteredArray addObject:item];
		}
	}

	if (filteredArray) {
		%orig([filteredArray copy]);
	} else {
		%orig(arg1);
	}
}

%end
%end

%ctor {
	Class ownerClass = objc_getClass("AWECommentLongPressPanelSwiftImpl.CommentLongPressPanelNormalSectionViewModel");
	if (ownerClass) {
		%init(DYYYFilterSetterGroup, HOOK_TARGET_OWNER_CLASS = ownerClass);
	}
}
