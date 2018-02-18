OBJECTS = mydetect

all: $(OBJECTS)

clean:
	rm -f $(OBJECTS)

mydetect: mydetect.c
	$(CXX) $^ -o $@ `opencv-config --cxxflags --libs highgui cvaux`
