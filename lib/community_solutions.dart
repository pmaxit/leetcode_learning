import 'dart:math';

import 'package:leetcode_api_dart/leetcode_api_dart.dart';

import 'communities.dart';

extension LeetcodeApiClientCustom on LeetcodeApiClient{

  Future<dynamic> getTopCommunityPosts({required String questionSlug, required String orderBy, required List<String> languageTags}) async{

    try{
      final data = await makeGraphQLRequest(getGraphQLTopCommunityPosts(questionSlug: questionSlug, orderBy: orderBy, languageTags: languageTags));
      final json = data['data']['questionSolutions']['solutions'];
      return (json as List).map((e) {
        var d = e as Map<String, dynamic>;
        d['questionSlug'] = questionSlug;
        return CommnityComment.fromJson(d);
      }).toList();

    }
    catch(e){
      print('error found');
      print(e);
    }
  }

  Future<dynamic> getProblemContent({required String questionSlug}) async{
    try{
      final data = await makeGraphQLRequest(getGraphQLQuestionData(questionSlug: questionSlug));
      final json = data['data']['question'];
      return json;
    }
    catch(e){
      print('error found');
      print(e);
    }
  }

  Future<dynamic> getOfficialSolution({required String questionSlug}) async {
    try{
      final data = await makeGraphQLRequest(getGraphQLOfficialSOlution(questionSlug: questionSlug));
      final json = data['data']['question'];
      return json;
    }
    catch(e){
      print('error found');
      print(e);
    }
  
  }
}

String getGraphQLTopCommunityPosts({required questionSlug, required orderBy, required List<String> languageTags}){
  return r'''{
    "query": "\n    query communitySolutions($questionSlug: String!, $skip: Int!, $first: Int!, $query: String, $orderBy: TopicSortingOption, $languageTags: [String!], $topicTags: [String!]) {\n  questionSolutions(\n    filters: {questionSlug: $questionSlug, skip: $skip, first: $first, query: $query, orderBy: $orderBy, languageTags: $languageTags, topicTags: $topicTags}\n  ) {\n  solutions {\n  id\n      title\n      commentCount\n      topLevelCommentCount\n      viewCount\n      pinned\n      isFavorite\n      solutionTags {\n        name\n        slug\n      }\n      post {\n    content\n    id\n   status\n        voteStatus\n        voteCount\n        creationDate\n        isHidden\n        author {\n          username\n          isActive\n          nameColor\n          activeBadge {\n            displayName\n            icon\n          }\n          profile {\n            userAvatar\n            reputation\n          }\n        }\n      }\n      searchMeta {\n        content\n        contentType\n        commentAuthor {\n          username\n        }\n        replyAuthor {\n          username\n        }\n        highlights\n      }\n    }\n  }\n}\n    ",
    "variables": {"query":"","languageTags":[#languageTags],"topicTags":[],"questionSlug":"#questionSlug","skip":0,"first":15,"orderBy":"#orderBy"},
    "operationName":"communitySolutions"
    }'''.replaceAll('#languageTags', languageTags.map((e) => '"$e"').join(','),
              ).replaceAll('#questionSlug', questionSlug)
              .replaceAll('#orderBy', orderBy);
}

String getGraphQLQuestionData({required questionSlug}){
  return r'''{
    "operationName": "questionContent",
    "query": "\n    query questionContent($titleSlug: String!) {\n  question(titleSlug: $titleSlug) {\n    content\n    mysqlSchemas\n    dataSchemas\n  }\n}\n    ",
    "variables": {"titleSlug":"#questionSlug"}
  }'''
  .replaceAll('#questionSlug', questionSlug);
}

String getGraphQLOfficialSOlution({required questionSlug}){
  return r'''{
    "operationName": "officialSolution",
    "variables": {
      "titleSlug": "#questionSlug"
    },
    "query": "\n query officialSolution($titleSlug: String!) {\n  question(titleSlug: $titleSlug) {\n    solution {\n      id\n      title\n      content\n      contentTypeId\n      paidOnly\n      hasVideoSolution\n      paidOnlyVideo\n      canSeeDetail\n      rating {\n        count\n        average\n        userRating {\n          score\n        }\n      }\n      topic {\n        id\n        commentCount\n        topLevelCommentCount\n        viewCount\n        subscribed\n        solutionTags {\n          name\n          slug\n        }\n        post {\n          id\n          status\n          creationDate\n          author {\n            username\n            isActive\n            profile {\n              userAvatar\n              reputation\n            }\n          }\n        }\n      }\n    }\n  }\n}\n    "
  }'''.replaceAll('#questionSlug', questionSlug);
}