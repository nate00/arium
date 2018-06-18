# This class wraps a ChunkyPNG::Canvas and adds some methods to it.

module Arium
  module Renderers
    class Drawing < SimpleDelegator

      def angle_between(x0, y0, x1, y1)
        Math.atan2(y1 - y0, x1 - x0)
      end

      # Mostly copied from ChunkyPNG::Canvas::Drawing#circle
      #
      # Reading this helped me figure out the code:
      #   http://groups.csail.mit.edu/graphics/classes/6.837/F98/Lecture6/circle.html
      #
      def arc(
        x0, y0, radius, radian_begin, radian_end,
        stroke_color = ChunkyPNG::Color::BLACK,
        fill_color = ChunkyPNG::Color::TRANSPARENT
      )
        stroke_color = ChunkyPNG::Color.parse(stroke_color)
        fill_color   = ChunkyPNG::Color.parse(fill_color)

        unless fill_color == ChunkyPNG::Color::TRANSPARENT
          raise "Fill isn't yet supported by #{__method__}"
        end

        unless [radian_begin, radian_end].all? { |r| (-Math::PI - 0.000001 .. Math::PI + 0.000001).include?(r) }
          raise "Radians out of range: (#{radian_begin}, #{radian_end})"
        end

        unless radian_begin <= radian_end + 0.000001
          raise "Radians out of order: #{radian_begin} > #{radian_end}"
        end

        is_in_sector = ->(x, y) do
          (radian_begin .. radian_end).include?(angle_between(x0, y0, x, y))
        end

        compose_if_in_sector = ->(x, y, color) do
          compose_pixel(x, y, color) if is_in_sector.(x, y)
        end

        # Some speculation:
        #
        # f = x**2 + y**2 - r**2
        #
        # f is called a "discriminating function." When it's zero, our current
        # point is on the circle's perimeter. When it's negative, we're inside
        # the circle. When positive, we're outside.
        #
        f = 1 - radius            # This is the first non-axis point: x=1, y~=radius, so f = 1**2 + radius**2 - radius**2.
        ddF_x = 1                 # A guess: this is how to update f when moving rightward.
        ddF_y = -2 * radius       # A guess: this is how to update f when moving upward.

        # We use these offsets to trace our progress along the circle's border.
        # The current point is (x0 + x, y0 + y).
        x = 0
        y = radius

        # Draw the four compass points of the circle.
        compose_if_in_sector.(x0, y0 + radius, stroke_color)
        compose_if_in_sector.(x0, y0 - radius, stroke_color)
        compose_if_in_sector.(x0 + radius, y0, stroke_color)
        compose_if_in_sector.(x0 - radius, y0, stroke_color)

        lines = [radius - 1] unless fill_color == ChunkyPNG::Color::TRANSPARENT

        # We start at the southernmost tip of the circle (0, radius), and
        # proceed counter-clockwise to trace one eighth of the circle. At each
        # point of our journey, we draw the current point, plus its reflections
        # over the circle's main axes and diagonal axes.
        #
        # The intention here is to draw a circle border that's one pixel thick.
        # At each step, the next point will either be to the right of the
        # previous, or up-and-to-the-right. (There are other parts of the circle
        # where the next point will be straight up, but not in this eighth.)
        while x < y

          # If the discriminating function is positive, then we're outside the
          # circle, and must go up to reenter. (We know we need to go up to
          # reenter because we're tracing our carefully chosen eighth.)
          if f >= 0
            y -= 1
            ddF_y += 2
            f += ddF_y
          end

          x += 1
          ddF_x += 2
          f += ddF_x

          unless fill_color == ChunkyPNG::Color::TRANSPARENT
            lines[y] = lines[y] ? [lines[y], x - 1].min : x - 1
            lines[x] = lines[x] ? [lines[x], y - 1].min : y - 1
          end

          # Draw our point (x0 + x, y0 + y) and its reflections over the
          # circle's main axes.
          compose_if_in_sector.(x0 + x, y0 + y, stroke_color)
          compose_if_in_sector.(x0 - x, y0 + y, stroke_color)
          compose_if_in_sector.(x0 + x, y0 - y, stroke_color)
          compose_if_in_sector.(x0 - x, y0 - y, stroke_color)

          # Now draw our point's reflections over the circle's diagonal axes
          # (unless the point is on an axis).
          unless x == y
            compose_if_in_sector.(x0 + y, y0 + x, stroke_color)
            compose_if_in_sector.(x0 - y, y0 + x, stroke_color)
            compose_if_in_sector.(x0 + y, y0 - x, stroke_color)
            compose_if_in_sector.(x0 - y, y0 - x, stroke_color)
          end
        end

        unless fill_color == ChunkyPNG::Color::TRANSPARENT
          lines.each_with_index do |length, y_offset|
            if length > 0
              line(x0 - length, y0 - y_offset, x0 + length, y0 - y_offset, fill_color)
            end
            if length > 0 && y_offset > 0
              line(x0 - length, y0 + y_offset, x0 + length, y0 + y_offset, fill_color)
            end
          end
        end

        __getobj__
      end
    end
  end
end
