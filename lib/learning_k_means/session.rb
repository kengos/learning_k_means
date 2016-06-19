module LearningKMeans
  class Session
    attr_accessor :centroids

    # @param dataset Array[Vector]
    def initialize(dataset, cluster_size, options = {})
      raise "cluster_size should be less than equal dataset size" if cluster_size >= dataset.size

      @dataset = dataset.clone
      @cluster_size = cluster_size
      @debug = options.delete(:debug)
    end

    def train(step = 5)
      @centroids = initialize_centroids

      if @debug
        puts "Initialize centroids"
        @centroids.each_with_index do |centroid, index|
          puts "  Cluster #{index}: #{centroid}"
        end
      end

      cluster_items = nil

      0.upto(step) do |i|
        puts "Train step #{i}" if @debug
        cluster_items = assign_cluster(@dataset, @centroids)
        @centroids = move_centorids(cluster_items)
        if @debug
          puts "  Cost: #{compute_cost(cluster_items, @centroids).to_f}"
        end
      end
      compute_cost(cluster_items, @centroids)
    end

    # 重心の初期化
    def initialize_centroids
      [].tap do |centroids|
        distinct_int_value(@cluster_size, @dataset.size).each do |index|
          centroids << @dataset[index]
        end
      end
    end

    def distinct_int_value(n, max)
      raise "Invalid argument: n: #{n}, max: #{max}" if n < 0 || max < 0 || n >= max

      Set.new.tap do |randoms|
        loop do
          randoms << rand(max)
          break if randoms.size == n
        end
      end.to_a
    end

    # データセットをクラスタに割当
    def assign_cluster(dataset, centroids)
      {}.tap do |cluster_items|
        dataset.each_with_index do |vector, i|
          cluster_index = select_cluster(vector, centroids)
          cluster_items[cluster_index] ||= []
          cluster_items[cluster_index] << vector
        end
      end
    end

    # 最も近い重心の選択
    def select_cluster(vector, centroids)
      index = nil
      min_distance = nil

      centroids.each_with_index do |centroid, i|
        distance = norm_square(vector, centroid)
        if min_distance.nil? || min_distance > distance
          min_distance = distance
          index = i
        end
      end
      index
    end

    # VectorX, VectorYのユークリッド距離の2乗の合計
    def norm_square(v_x, v_y)
      (v_x - v_y).map{|v| v * v }.inject(:+)
    end

    # 重心の再移動
    def move_centorids(cluster_items)
      [].tap do |o|
        cluster_items.each_pair do |cluster_index, items|
          puts "  Cluster #{cluster_index}: #{items.inject(:+)}" if @debug
          o[cluster_index] = items.inject(:+) / items.size
        end
      end
    end

    def compute_cost(cluster_items, centroids)
      [].tap do |cost|
        cluster_items.each do |cluster_index, items|
          cost[cluster_index] = items.map {|item| norm_square(item, centroids[cluster_index]) }.inject(:+)
        end
      end.inject(:+)
    end

    def labeled!(labeled_dataset, centroids)
      {}.tap do |result|
        labeled_dataset.each_pair do |label, dataset|
          result[label] = select_cluster(dataset, centroids)
        end
      end
    end
  end
end