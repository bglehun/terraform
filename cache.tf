resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "${var.app_name}-redis-subnet-group"
  subnet_ids = concat(aws_subnet.public_subnet.*.id, aws_subnet.private_subnet.*.id)
}

# non-cluster mode는 replication group만 생성함.
resource "aws_elasticache_replication_group" "redis_replication_group" {
  replication_group_id       = "${var.app_name}-redis-replica-group"
  description                = "${var.app_name} replication group"
  node_type                  = "cache.t4g.micro"
  port                       = 6379
  num_cache_clusters         = 2
  automatic_failover_enabled = true
  subnet_group_name          = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids         = [aws_security_group.redis_sg.id]

  tags = {
    Name = "${var.app_name}-redis"
  }

  #  lifecycle {
  #    ignore_changes = [num_cache_clusters]
  #  }
}

#resource "aws_elasticache_cluster" "redis_cluster" {
#  count = 1
#  cluster_id           = "${var.app_name}-redis-rep-group-${count.index}"
#  replication_group_id = aws_elasticache_replication_group.redis_replication_group.id
#}
