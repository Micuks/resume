# Flink StateBackend CacheKit 测试报告（Nexmark 0.3 / 100M）

## 1. 测试目的
- 对比 `RocksDB StateBackend` 与 `CacheKit ValueState` 在 Nexmark 基准下的吞吐表现。
- 验证 `flink-statebackend-cachekit` 在 `Flink 1.16.3` 上的使能方式和收益。

## 2. 软件版本
- Flink: `1.16.3`
- Java: `1.8.0`
- Nexmark: `0.3`
- Linux Kernel: `5.10.0-153.56.0.134.oe2203sp2.aarch64`
- CacheKit 测试提交:
  - `2025-1-27`: `85f609a290`
  - `2025-2-2`: `2bf60ca5a7`

## 3. 包使能方式
1. 将 `flink-statebackend-cachekit` 编译产物 JAR 放入 `flink/lib`。
2. 在 `flink-conf.yaml` 中配置：

```yaml
state.backend: org.apache.flink.contrib.streaming.state.cachekit.CacheKitStateBackendFactory

# 设置缓存大小
state.backend.cachekit.value.cache.max-entries: 8000
state.backend.cachekit.value.cache.policy: LRU
state.backend.cachekit.value.cache.lru.overflow: 1024

state.backend.cachekit.value.bypass.enabled: false
state.backend.cachekit.value.hit-rate.threshold: 0.01
state.backend.cachekit.value.hit-rate.window: 5000
```

## 4. 测试环境与规格
- 架构: `aarch64`（Little Endian）
- CPU: `HiSilicon Kunpeng 920 7280Z`
- 逻辑 CPU: `320`
- Socket: `2`（每 Socket `80` Core，`2` 线程/核）
- 频率范围: `400 MHz ~ 2900 MHz`
- NUMA: `4` 节点（0-79 / 80-159 / 160-239 / 240-319）
- Cache: L1d `10 MiB`、L1i `10 MiB`、L2 `200 MiB`、L3 `280 MiB`

## 5. 测试用例
- 基准: `Nexmark 0.3`
- 数据规模: `100M`
- 指标单位: `K events/s`
- 对比对象: `RocksDB` vs `CacheKit`
- 查询集合: `q4/q5/q7/q8/q9/q11/q12/q15/q16/q17/q18`
- 每个查询多次运行，表中采用 `Avg` 列作为统计值。

## 6. 测试结果（2025-1-27）
- 参数: `100M/Lru/8000/256/0.03/5000/valuestate_cache_only/bypass/no_mini-batch/commit: 85f609a290`
- 全部查询综合提升（表内汇总）: **33.48%**

| Query | RocksDB Avg (K events/s) | CacheKit Avg (K events/s) | 提升 |
|---|---:|---:|---:|
| q4 | 15.102 | 16.970 | 12.37% |
| q5 | 34.125 | 33.660 | -1.36% |
| q8 | 88.280 | 85.050 | -3.66% |
| q9 | 9.670 | 9.593 | -0.79% |
| q11 | 20.872 | 24.640 | 18.05% |
| q18 | 27.664 | 42.423 | 53.35% |
| q7 | 16.262 | 16.293 | 0.19% |
| q12 | 76.200 | - | - |
| q15 | 11.363 | 25.150 | 121.34% |
| q16 | 3.510 | 6.170 | 75.78% |
| q17 | 43.225 | 68.975 | 59.57% |

## 6. 测试结果（2025-2-2）
- 参数: `100M/Lru/8000/256/0.03/5000/valuestate_cache_only/no_mini-batch/commit: 2bf60ca5a7`
- 全部查询综合提升（表内汇总）: **30.18%**

| Query | RocksDB Avg (K events/s) | CacheKit Avg (K events/s) | 提升 |
|---|---:|---:|---:|
| q4 | 14.786 | 17.504 | 18.38% |
| q5 | 34.700 | 40.282 | 16.09% |
| q8 | 88.094 | 85.412 | -3.04% |
| q9 | 9.760 | 9.760 | 0.00% |
| q11 | 20.716 | 24.426 | 17.91% |
| q18 | 27.832 | 42.142 | 51.42% |
| q7 | 15.354 | 16.144 | 5.15% |
| q12 | 72.872 | 73.408 | 0.74% |
| q15 | 11.110 | 23.742 | 113.70% |
| q16 | 4.042 | 6.048 | 49.63% |
| q17 | 43.308 | 70.158 | 62.00% |

## 7. 结果解读
- 两轮测试综合提升分别为 `33.48%`（2025-01-27）与 `30.18%`（2025-02-02），整体为正收益。
- 增益较明显的查询: `q11/q15/q16/q17/q18`。
- 回退或收益不明显的查询: `q8`（两轮均回退），`q9`（基本持平），`q5`（首轮小幅回退、次轮转正）。
- `2025-01-27` 的 `q12` 在汇总表缺少 CacheKit Avg/Increase，建议补测以便横向对齐。

## 8. 结论
- 在当前硬件与参数组合下，`CacheKit ValueState` 在 Nexmark 100M 场景下可稳定提供约 `30%+` 的整体吞吐提升。
- 建议上线前重点复核 `q8` 类模式（回退场景）的访问特征，并结合命中率窗口参数做专项调优。