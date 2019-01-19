# frozen_string_literal: true

trap('HUP') do
  Pgq::Worker.shutdown!('HUP')
end
trap('TERM') do
  Pgq::Worker.shutdown!('TERM')
end
trap('INT') do
  Pgq::Worker.shutdown!('INT')
end
