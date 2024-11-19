data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

#USER
resource "aws_iam_user" "main" {
  for_each = toset(var.iam_list)
  name     = each.key
  tags     = var.tag_project
  depends_on = [
    aws_iam_policy.main
  ]
}

data "template_file" "policy" {
  for_each = toset(var.iam_list)
  template = file("${path.root}/policy/iam/${each.key}.json")
  vars = {
    region     = data.aws_region.current.name
    account_id = data.aws_caller_identity.current.account_id
    prefix     = "${var.aws_prefix}"
    project    = "${var.aws_project}"
    env        = "${var.aws_env}"
  }
  depends_on = [
    data.aws_caller_identity.current,
  data.aws_region.current]
}

resource "aws_iam_policy" "main" {
  for_each    = toset(var.iam_list)
  name        = each.key
  description = "Policy for project ${var.aws_project}"
  policy      = data.template_file.policy[each.key].rendered
  tags        = var.tag_project
  depends_on = [
    data.template_file.policy
  ]
}

resource "aws_iam_policy_attachment" "main" {
  for_each   = toset(var.iam_list)
  name       = "${var.aws_project}-${each.key}-attach"
  users      = ["${each.key}"]
  roles      = []
  groups     = []
  policy_arn = aws_iam_policy.main[each.key].arn
  depends_on = [
    aws_iam_user.main,
    aws_iam_policy.main
  ]
}

resource "aws_iam_access_key" "main" {
  for_each = toset(var.iam_list)
  user     = aws_iam_user.main[each.key].name
}


#ECS
data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "template_file" "policy_ecs" {
  template = file("${path.root}/policy/iam/sys_ecs_role.json")
  vars = {
    region     = data.aws_region.current.name
    account_id = data.aws_caller_identity.current.account_id
    prefix     = "${var.aws_prefix}"
    project    = "${var.aws_project}"
  }
  depends_on = [
    data.aws_region.current,
    data.aws_caller_identity.current
  ]
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.aws_prefix}-${var.aws_project}-ECS"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
  depends_on = [
    data.aws_iam_policy_document.ecs_task_execution_role
  ]
}

resource "aws_iam_policy" "ecs" {
  name        = "ecs-role-${var.aws_project}"
  description = "Policy for project ${var.aws_project} for ecs"
  policy      = data.template_file.policy_ecs.rendered
  tags        = var.tag_project
  depends_on = [
    data.template_file.policy_ecs
  ]
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs.arn
  depends_on = [
    aws_iam_policy.ecs,
    aws_iam_role.ecs_task_execution_role
  ]
}
