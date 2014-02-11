PKG = com/allsparkcube
THRIFT_DIR = ../../thrift/gen-java/$(PKG)
THRIFT_IMPL_FILE = CubeInterface.java
SRC_DIR = src/main/java/$(PKG)
DEMO_DIR = demo
DEMO_CLASSNAME = CubeDemo
JAR_FILE = `find target -name "cube_client*standalone.jar"`

jar: clean
	@cp $(THRIFT_DIR)/$(THRIFT_IMPL_FILE) $(SRC_DIR)
	@mvn package

run: jar
	@javac -cp $(JAR_FILE) $(DEMO_DIR)/$(DEMO_CLASSNAME).java
	@java -cp $(JAR_FILE):$(DEMO_DIR) $(DEMO_CLASSNAME)

clean:
	@-rm -f $(SRC_DIR)/$(THRIFT_IMPL_FILE)
	@mvn clean

.PHONY: jar run clean

