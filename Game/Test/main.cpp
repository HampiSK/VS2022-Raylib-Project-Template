#include <gtest/gtest.h>
#include <gmock/gmock.h>

int main(int argc, char **argv)
{
    // Initializes Google Test.
    ::testing::InitGoogleTest(&argc, argv);
    ::testing::InitGoogleMock(&argc, argv);

    // Runs all the tests.
    const int result = RUN_ALL_TESTS();

    return result;
}
