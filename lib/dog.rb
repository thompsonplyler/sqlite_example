class Dog < Savable

  attr_accessor :name, :birthdate, :breed, :image_url, :last_fed_at, :last_walked_at
  attr_reader :id

  def dog_walks
    DogWalk.all.select { |dw| dw.dog == self }
  end

  def walks
    dog_walks.map { |dw| dw.walk }
  end

  def walk
    new_walk = Walk.create(time: Time.now)
    dw = DogWalk.create(
      dog: self
    )
    dw.walk = new_walk
    new_walk
  end
  
  def feed
    Feeding.create(time: Time.now, dog_id: self.id, food: "chow")
    self
  end

  def feedings
    Feeding.all.select { |feeding| feeding.dog_id == self.object_id }
  end

  # print details about a dog (including the last walked at and last fed at times)
  def print
    puts
    puts self.name.green
    puts "  Age: #{self.age}"
    puts "  Breed: #{self.breed}"
    puts "  Image Url: #{self.image_url}"
    puts "  Last walked at: #{format_time(self.last_walked_at)}"
    puts "  Last fed at: #{format_time(self.last_fed_at)}"
    puts
  end


  private

  def formatted_name
    if self.last_fed_at.nil? && self.last_walked_at.nil?
      "#{self.name} (hungry and needs a walk)".red
    elsif self.last_fed_at.nil?
      "#{self.name} (hungry)".red
    elsif self.last_walked_at.nil?
      "#{self.name} (needs a walk)".red
    else
      self.name.green
    end
  end

  def format_time(time)
    time && time.strftime('%l:%M %p on %Y-%m-%d')
  end
end

