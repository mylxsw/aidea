import 'package:flutter/material.dart';

// 客户端应用版本号
const clientVersion = '1.0.13';
// 本地数据库版本号
const databaseVersion = 26;

const maxRoomNumForNonVIP = 50;
const coinSign = '个';

const settingAPIServerToken = 'api-token';
const settingUserInfo = 'user-info';
const settingUsingGuestMode = 'using-guest-mode';

const settingForceShowLab = 'force-show-lab';

const chatAnywhereModel = 'openai:gpt-3.5-turbo';
const chatAnywhereRoomId = 1;

const creativeIslandModelTypeText = 'text-generation';
const creativeIslandModelTypeImage = 'image-generation';
const creativeIslandModelTypeImageToImage = 'image-to-image';

const creativeIslandCompletionTypeText = 'text';
const creativeIslandCompletionTypeBase64Image = 'base64-images';
const creativeIslandCompletionTypeURLImage = 'url-images';

// 用于标识是否已经加载过引导页
// 只有在第一次安装的时候才会加载引导页
const settingOnBoardingLoaded = 'on-boarding-loaded';
const settingLanguage = 'language';
const settingServerURL = 'server-url';
// 背景图片
const settingBackgroundImage = 'background-image';
const settingBackgroundImageBlur = 'background-image-blur';

const settingOpenAISelfHosted = 'openai-self-hosted';
const settingDeepAISelfHosted = 'deepai-self-hosted';
const settingStabilityAISelfHosted = 'stabilityai-self-hosted';
const settingImageManagerSelfHosted = 'image-manager-self-hosted';

const settingThemeMode = "dark-mode";
const settingImglocToken = 'imgloc-token';
const chatMessagePerPage = 300;
const contextBreakKey = 'context-break';
const defaultChatModel = 'gpt-3.5-turbo';
const defaultChatModelName = 'GPT-3.5';
const defaultImageModel = 'DALL·E';
const defaultModelNotChatDesc = '该模型不支持上下文，只能一问一答';

// AI 模型类型
const modelTypeOpenAI = 'openai';
const modelTypeDeepAI = 'deepai';
const modelTypeLeapAI = "leapai";
const modelTypeStabilityAI = 'stabilityai';
const modelTypeFromston = 'fromston';
const modelTypeGetimg = 'getimgai';

final modelTypeTagColors = <String, Color>{
  modelTypeOpenAI: Colors.blue,
  modelTypeDeepAI: Colors.green,
  modelTypeStabilityAI: Colors.purple,
  modelTypeLeapAI: Colors.orange,
  modelTypeFromston: Colors.blueAccent,
  modelTypeGetimg: Colors.pinkAccent,
};

// OpenAI 相关设置
const settingOpenAIAPIToken = "openai-token";
const settingOpenAIOrganization = 'openai-organization';
const settingOpenAITemperature = "openai-temperature";
const settingOpenAIModel = "openai-model";
const settingOpenAIURL = "openai-url";
const defaultOpenAIServerURL = 'https://api.openai.com';

// DeepAI 相关设置
const settingDeepAIURL = 'deepai-url';
const settingDeepAIAPIToken = 'deepai-token';
const defaultDeepAIServerURL = 'https://api.deepai.org';

// StabilityAI 相关设置
const settingStabilityAIURL = 'stabilityai-url';
const settingStabilityAIAPIToken = 'stabilityai-token';
const settingStabilityAIOrganization = 'stabilityai-organization';
const defaultStabilityAIURL = 'https://api.stability.ai';

// 微信配置
const weixinAppId = 'wx52cc036cc770406d';
const universalLink = 'https://ai.aicode.cc/wechat-login/';

// 图床信息
const qiniuImageTypeAvatar = 'avatar';
const qiniuImageTypeThumb = 'thumb';
const qiniuImageTypeThumbMedium = 'thumb_500';
