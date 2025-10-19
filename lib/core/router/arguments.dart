
class UserPostsArguments {
  String? username;
  Function? reload;
  UserPostsArguments({this.username, this.reload});
}

class PostDataArguments {
  String? postId;
  String? username;
  String? postAuther;
  PostDataArguments({this.username, this.postAuther, this.postId});
}