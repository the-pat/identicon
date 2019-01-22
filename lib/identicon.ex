defmodule Identicon do
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  @doc """
    Hash the given string and return a list of 16 numbers

  ## Examples

      iex> Identicon.hash_input("hello world!")
      %Identicon.Image{
        color: nil,
        hex: [252, 63, 249, 142, 140, 106, 13, 48, 135, 213, 21, 192, 71, 63, 134,
         119]
      }

  """
  def hash_input(input) do
    hex =
      :crypto.hash(:md5, input)
      |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  @doc """
    Take the first three hex values from the image as the RGB value

  ## Examples

      iex> image = %Identicon.Image{hex: [1, 2, 3, 4]}
      iex> Identicon.pick_color(image)
      %Identicon.Image{color: {1, 2, 3}, hex: [1, 2, 3, 4]}

  """
  def pick_color(%Identicon.Image{hex: [r, g, b | _]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  @doc """
    Build a 5x5 grid from the hex values

  ## Examples

      iex> image = %Identicon.Image{hex: [1, 2, 3, 4, 5, 6]}
      iex> Identicon.build_grid(image)
      %Identicon.Image{
        color: nil,
        grid: [{1, 0}, {2, 1}, {3, 2}, {2, 3}, {1, 4},
          {4, 5}, {5, 6}, {6, 7}, {5, 8}, {4, 9}],
        hex: [1, 2, 3, 4, 5, 6]
      }

  """
  def build_grid(%Identicon.Image{hex: hex_list} = image) do
    grid =
      hex_list
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end

  @doc """
    Return the mirrored row

  ## Examples

      iex> row = [145, 46, 200]
      iex> Identicon.mirror_row(row)
      [145, 46, 200, 46, 145]
  """
  def mirror_row(row) do
    [first, second | _] = row
    row ++ [second, first]
  end

  @doc """
    Remove all of the odd valued squares from the grid

  ## Examples

      iex> image = %Identicon.Image{grid: [{1, 1}, {2, 2}]}
      iex> Identicon.filter_odd_squares(image)
      %Identicon.Image{color: nil, grid: [{2, 2}], hex: nil}
  """
  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    filtered_grid =
      Enum.filter grid, fn {number, _} ->
        rem(number, 2) == 0
      end

    %Identicon.Image{image | grid: filtered_grid}
  end

  @doc """
    Generate the top-left and bottom-right coordinates for each index in the grid

  ## Examples

      iex> image = %Identicon.Image{grid: [{2, 0}, {4, 1}, {6, 5}]}
      iex> Identicon.build_pixel_map(image)
      %Identicon.Image{
        color: nil,
        grid: [{2, 0}, {4, 1}, {6, 5}],
        hex: nil,
        pixel_map: [{{0, 0}, {60, 60}}, {{60, 0}, {120, 60}}, {{0, 60}, {60, 120}}]
      }
  """
  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map =
      Enum.map grid, fn {_, index} ->
        horizontal = rem(index, 5) * 60
        vertical = div(index, 5) * 60

        top_left = {horizontal, vertical}
        bottom_right = {horizontal + 60, vertical + 60}

        {top_left, bottom_right}
      end

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  @doc """
    Generate the image
  """
  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(300, 300)
    fill = :egd.color(color)

    Enum.each pixel_map, fn {start, stop} ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  @doc """
    Save the image to a file
  """
  def save_image(image, input) do
    File.write("#{input}.png", image)
  end
end
