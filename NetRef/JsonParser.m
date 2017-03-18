//
//  HttpJsonParser.m
//  NetRef
//
//  Created by wenguang pan on 2017/3/14.
//  Copyright © 2017年 wenguang pan. All rights reserved.
//

#import "JsonParser.h"
#import <objc/runtime.h>
#import "HttpResponse.h"
#import "HttpError.h"

@implementation JsonParser


//-(VSDResponse *)parseJSON:(id)jsonObject modelClass:(Class)modelClass {
//    VSDResponse *response = nil;
//    
//    // 返回的json为数组.
//    NSMutableArray *parsedArray = [[NSMutableArray alloc] init];
//    
//    unsigned int propertyCount, i;
//    objc_property_t *properties = class_copyPropertyList(modelClass, &propertyCount);
//    
//    SEL setArrayPropertyMethod = nil;   // modelClass的数组属性对应的set方法, eg, -(void)setUsers:(NSArray *)users.
//    NSString *propertyName;
//    
//    NSArray *jsonArray = (NSArray *)jsonObject;
//    id firstObject = [jsonArray firstObject];
//    
//    // 遍历model的property, 并找出属性类型为数组的属性, 并以此属性名获得对应的set方法.
//    for (i = 0; i < propertyCount; i++)
//    {
//        objc_property_t property = properties[i];
//        
//        // get property name and type.
//        const char *propertyName_char = property_getName(property);
//        char *propertyType_char = property_copyAttributeValue(property, "T");
//        propertyName = [[NSString alloc] initWithCString:propertyName_char encoding:NSUTF8StringEncoding];
//        NSString *propertyType = [[NSString alloc] initWithCString:propertyType_char encoding:NSUTF8StringEncoding];
//        free(propertyType_char);
//        
//        if([propertyType isEqualToString:@"@\"NSArray\""] || [propertyType isEqualToString:@"@\"NSMutableArray\""])
//        {
//            // 当前property为数组类型.
//            setArrayPropertyMethod = [self setMethodFromPropertyName:propertyName];
//            break;
//        }
//    }
//    
//    response = [[modelClass alloc] init];
//    
//    if ([[firstObject class] isSubclassOfClass:[NSDictionary class]]) {
//        Class objectClass = nil;            // modelClass的数组属性的元素类型, eg, users里面是VSUser对象, objectClass 就是VSUser class.
//        SEL typeOfClassMethod = [self typeOfClassMethodFromPropertyName:propertyName];
//        if ([response respondsToSelector:typeOfClassMethod]) {
//            objectClass = [self savePerformSelectorForModle:response selector:typeOfClassMethod parameterObject:nil];
//        }
//        
//        if (objectClass) {
//            for (NSDictionary *currentObject in jsonArray) {
//                [parsedArray addObject:[self runtimeParseObject:objectClass jsonDictionary:currentObject]];
//            }
//        }
//    }else {
//        // 返回的json数组元素是NSNumber、NSString、NSArray、NSNull.
//        [parsedArray addObjectsFromArray:jsonArray];
//    }
//    
//    [self savePerformSelectorForModle:response selector:setArrayPropertyMethod parameterObject:parsedArray];
//    
//    free(properties);
//    
//    return response;
//    
//}

- (HttpResponse *)parseJSON:(id)jsonObject modelClass:(Class)modelClass
{
    HttpResponse *response = [HttpResponse new];
    response.code = [[jsonObject valueForKey:@"code"] integerValue];
    response.message = [jsonObject valueForKey:@"message"];
    
    id data = [jsonObject valueForKey:@"data"];
    id model = [modelClass new];
    if ([data isKindOfClass:[NSDictionary class]])
    {
        model = [self runtimeParseObject:modelClass jsonDictionary:data];
    }
    else if ([data isKindOfClass:[NSArray class]])
    {
        //TODO:data为数组
    }
    response.data = model;
    return response;
}

#pragma mark - Runtime解析方法

- (SEL)setMethodFromPropertyName:(NSString *)propertyName
{
    NSString *setMethodString
    = [NSString stringWithFormat:@"set%@%@:", [[propertyName substringToIndex:1] uppercaseString], [propertyName substringFromIndex:1]];
    return NSSelectorFromString(setMethodString);
}

- (SEL)typeOfClassMethodFromPropertyName:(NSString *)propertyName
{
    NSString *typeOfClassMethodString = [NSString stringWithFormat:@"typeOf%@", propertyName];
    return NSSelectorFromString(typeOfClassMethodString);
}

- (id)savePerformSelectorForModle:(id)model selector:(SEL)selector parameterObject:(id)object
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [model performSelector:selector withObject:object];
#pragma clang diagnostic pop
}

- (void)setProperties:(objc_property_t *)properties
      propertiesCount:(unsigned int)propertyCount
             forModel:(id)model
       jsonDictionary:(NSDictionary *)jsonDictionary
{
    unsigned int i;
    
    // 遍历model的property.
    for (i = 0; i < propertyCount; i++)
    {
        objc_property_t property = properties[i];
        
        // get property name and type.
        const char *propertyName_char = property_getName(property);
        char *propertyType_char = property_copyAttributeValue(property, "T");
        NSString *propertyName = [[NSString alloc] initWithCString:propertyName_char encoding:NSUTF8StringEncoding];
        NSString *propertyType = [[NSString alloc] initWithCString:propertyType_char encoding:NSUTF8StringEncoding];
        
        // get property's set methods.
        SEL setMethod = [self setMethodFromPropertyName:propertyName];
        
        id jsonValue = [jsonDictionary valueForKey:propertyName];
        
        if (!jsonValue || [[jsonValue class] isSubclassOfClass:[NSNull class]])
        {
            // 如果服务端返回null，则continue.
            continue;
        }
        
         // 对象
        if ([propertyType hasPrefix:@"@"])
        {
            // 注意，对象数据不能用NSInvocation调用，会有内存问题，会因非法访问对象内存而崩溃!!!
            if ([propertyType isEqualToString:@"@\"NSString\""] || [propertyType isEqualToString:@"@\"NSMutableString\""])
            {
                // 对象属性是字符串.
                NSString *propertyValue = nil;
                if ([[jsonValue class] isSubclassOfClass:[NSString class]])
                {
                    propertyValue = (NSString *)jsonValue;
                }
                else if ([[jsonValue class] isSubclassOfClass:[NSNumber class]])
                {
                    propertyValue = [(NSNumber *)jsonValue stringValue];
                }
                [self savePerformSelectorForModle:model selector:setMethod parameterObject:propertyValue];
            }
            else if ([propertyType isEqualToString:@"@\"NSArray\""] || [propertyType isEqualToString:@"@\"NSMutableArray\""])
            {
                // 对象属性是数组.
                if ([[jsonValue class] isSubclassOfClass:[NSArray class]])
                {
                    NSArray *jsonArray = (NSArray *)jsonValue;
                    NSMutableArray *array = [[NSMutableArray alloc] init];
                    if ([jsonArray count] > 0)
                    {
                        // 注意：如果数组的元素又是数组（多维数组），仅仅将第2维数组作为第1维数组的元素，不会从第2维数组逐层深入并全部转换成对应的model.
                        id arrayObject = [jsonArray firstObject];
                        if ([[arrayObject class] isSubclassOfClass:[NSNumber class]]
                            || [[arrayObject class] isSubclassOfClass:[NSString class]]
                            || [[arrayObject class] isSubclassOfClass:[NSArray class]])
                        {
                            for (id currentValue in jsonArray)
                            {
                                if (currentValue && ![[currentValue class] isSubclassOfClass:[NSNull class]])
                                {
                                    [array addObject:currentValue];
                                }
                            }
                        }
                        else if ([[arrayObject class] isSubclassOfClass:[NSDictionary class]])
                        {
                            for (id currentValue in jsonArray)
                            {
                                id currentObject = currentValue;
                                SEL typeOfClassMethod = [self typeOfClassMethodFromPropertyName:propertyName];
                                if ([model respondsToSelector:typeOfClassMethod])
                                {
                                    Class theModelClass = [self savePerformSelectorForModle:model selector:typeOfClassMethod parameterObject:nil];
                                    currentObject = [self runtimeParseObject:theModelClass jsonDictionary:(NSDictionary *)currentValue];
                                }
                                if (currentObject && ![[currentObject class] isSubclassOfClass:[NSNull class]])
                                {
                                    [array addObject:currentObject];
                                }
                            }
                        }
                    }
                    [self savePerformSelectorForModle:model selector:setMethod parameterObject:array];
                }
            }
            else if ([propertyType isEqualToString:@"@\"NSDictionary\""] || [propertyType isEqualToString:@"@\"NSMutableDictionary\""])
            {
                // 对象属性是字典.
                // 字典一般要封装成一个model处理，不建议在model中直接有一个property的类型是NSDictionary.
                [self savePerformSelectorForModle:model selector:setMethod parameterObject:(NSDictionary *)jsonValue];
            }
            else if ([propertyType isEqualToString:@"@"])
            {
                // id
                [self savePerformSelectorForModle:model selector:setMethod parameterObject:jsonValue];
            }
            else
            {
                // 对象属性是自定义对象, eg, VSUser...
                if ([[jsonValue class] isSubclassOfClass:[NSDictionary class]])
                {
                    NSDictionary *modelDictionary = (NSDictionary *)jsonValue;
                    SEL typeOfClassMethod = [self typeOfClassMethodFromPropertyName:propertyName];
                    id currentObject = nil;
                    if ([model respondsToSelector:typeOfClassMethod])
                    {
                        Class theModelClass = [self savePerformSelectorForModle:model selector:typeOfClassMethod parameterObject:nil];
                        currentObject = [self runtimeParseObject:theModelClass jsonDictionary:modelDictionary];
                    }
                    [self savePerformSelectorForModle:model selector:setMethod parameterObject:currentObject];
                }
            }
        }
        else
        {
            // 基本数据类型
            
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[model methodSignatureForSelector:setMethod]];
            [invocation setSelector:setMethod];
            [invocation setTarget:model];
            
            NSNumber *propertyValue = nil;
            if ([[jsonValue class] isSubclassOfClass:[NSNumber class]])
            {
                propertyValue = (NSNumber *)jsonValue;
            }
            else if ([[jsonValue class] isSubclassOfClass:[NSString class]])
            {
                if ([(NSString *)jsonValue isEqualToString:@"true"] || [(NSString *)jsonValue isEqualToString:@"1"])
                {
                    propertyValue = [NSNumber numberWithBool:YES];
                }
                else if ([(NSString *)jsonValue isEqualToString:@"false"] || [(NSString *)jsonValue isEqualToString:@"0"])
                {
                    propertyValue = [NSNumber numberWithBool:NO];
                }
                else
                {
                    NSNumberFormatter *formatString = [[NSNumberFormatter alloc] init];
                    propertyValue = [formatString numberFromString:(NSString *)jsonValue];
                }
            }
            
            if ([propertyType isEqualToString:@"B"])
            {
                // BOOL, bool.
                BOOL boolValue = [propertyValue boolValue];
                [invocation setArgument:&boolValue atIndex:2];
            }
            else if ([propertyType isEqualToString:@"s"])
            {
                // short
                short shortValue = [propertyValue shortValue];
                [invocation setArgument:&shortValue atIndex:2];
                
            }
            else if ([propertyType isEqualToString:@"S"])
            {
                // unsigned short
                unsigned short unsignedShortValue = [propertyValue unsignedShortValue];
                [invocation setArgument:&unsignedShortValue atIndex:2];
                
            }
            else if ([propertyType isEqualToString:@"i"])
            {
                // enum, int
                int intValue = [propertyValue intValue];
                [invocation setArgument:&intValue atIndex:2];
                
            }
            else if ([propertyType isEqualToString:@"I"])
            {
                // unsigned int
                unsigned int unsignedIntValue = [propertyValue unsignedIntValue];
                [invocation setArgument:&unsignedIntValue atIndex:2];
                
            }
            
            // "l"在64位机器中被视为32位 http://nshipster.com/type-encodings/
            // 各类型长度对照： https://developer.apple.com/library/ios/documentation/General/Conceptual/CocoaTouch64BitGuide/Major64-BitChanges/Major64-BitChanges.html
            else if ([propertyType isEqualToString:@"l"])
            {
                // int32_t
                int32_t int32Value = [propertyValue intValue];
                [invocation setArgument:&int32Value atIndex:2];
            }
            else if ([propertyType isEqualToString:@"L"])
            {
                // UInt32
                UInt32 uint32Value = [propertyValue unsignedIntValue];
                [invocation setArgument:&uint32Value atIndex:2];
            }
            else if ([propertyType isEqualToString:@"q"])
            {
                // long long
                int64_t int64Value = [propertyValue longLongValue];
                [invocation setArgument:&int64Value atIndex:2];
            }
            else if ([propertyType isEqualToString:@"Q"])
            {
                // unsigned long long
                UInt64 uint64Value = [propertyValue unsignedLongLongValue];
                [invocation setArgument:&uint64Value atIndex:2];
            }
            else if ([propertyType isEqualToString:@"d"])
            {
                // double
                double doubleValue = [propertyValue doubleValue];
                [invocation setArgument:&doubleValue atIndex:2];
                
            }
            else if ([propertyType isEqualToString:@"f"])
            {
                // float
                float floatValue = [propertyValue floatValue];
                [invocation setArgument:&floatValue atIndex:2];
            }
            else if ([propertyType isEqualToString:@"c"])
            {
                // char
                char charValue = [propertyValue charValue];
                [invocation setArgument:&charValue atIndex:2];
            }
            else if ([propertyType isEqualToString:@"C"])
            {
                // unsigned char
                unsigned char unsignedCharValue = [propertyValue unsignedCharValue];
                [invocation setArgument:&unsignedCharValue atIndex:2];
            }
            
            [invocation invoke];
        }
        
        free(propertyType_char);
    }
}

- (void)setPerportiesForModel:(id)model
            currentLevelClass:(Class)currentLevelClass
               jsonDictionary:(NSDictionary *)jsonDictionary
{
    
    // 这里的递归调用是为了完全解析出自定义model的父类字段. 因为class_copyPropertyList不会获取父类属性.
    if (![NSStringFromClass(currentLevelClass) isEqualToString:@"NSObject"])
    {
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList(currentLevelClass, &propertyCount);
        [self setProperties:properties propertiesCount:propertyCount forModel:model jsonDictionary:jsonDictionary];
        free(properties);
        
        Class superClass = class_getSuperclass(currentLevelClass);
        [self setPerportiesForModel:model currentLevelClass:superClass jsonDictionary:jsonDictionary];
    }
}

- (id)runtimeParseObject:(Class)modelClass jsonDictionary:(NSDictionary *)jsonDictionary
{
    id model = [[modelClass alloc] init];
    [self setPerportiesForModel:model currentLevelClass:modelClass jsonDictionary:jsonDictionary];
    return model;
}

@end
